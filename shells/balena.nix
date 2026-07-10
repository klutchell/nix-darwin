{pkgs}: let
  # Common packages for all environments
  commonPackages = with pkgs; [
    awscli2
    k9s
    kubectl
    kubeseal
    saml2aws
    fluxcd
    # (python3.withPackages (p:
    #   with p; [
    #     (buildPythonPackage rec {
    #       pname = "awscli-saml";
    #       version = "2.0.2";
    #       src = fetchPypi {
    #         inherit pname version;
    #         sha256 = "sha256-rQt985S0pYxKL7Z6vrQr/DhhVs6NUcdzL67N5kXQ1Q8=";
    #       };
    #       propagatedBuildInputs = [
    #         boto3
    #         botocore
    #         lxml
    #         requests
    #         pip
    #       ];
    #     })
    #   ]))
  ];

  # saml2aws 2.36.19 bundles playwright-go v0.4702.0, whose driver is fetched
  # from playwright.azureedge.net — a CDN Microsoft retired 2026-07-08, so login
  # 404s on the driver download (Versent/saml2aws#1531). playwright-go < v0.6100.0
  # can't self-bootstrap anymore. Reconstruct the driver from the still-live npm
  # playwright-core package (the exact thing newer playwright-go assembles); the
  # shellHook links this + a node binary into the cache dir saml2aws checks, so
  # the up-to-date probe passes and the dead download is never attempted.
  playwrightGoDriver = pkgs.runCommand "ms-playwright-go-1.47.2" {
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/playwright-core/-/playwright-core-1.47.2.tgz";
      hash = "sha512-3JvMfF+9LJfe16l7AbSmU555PaTl2tPyQsVInqm3id16pdDfvZ8TTZ/pyzmkbDrZTQefyzU7AIHlZqQnxpqHVQ==";
    };
  } ''
    mkdir -p $out
    tar -xzf $src -C $out
  '';

  # Function to create environment-specific shells
  mkBalenaShell = {
    name,
    profile,
    context,
    cluster,
    account,
    region ? "us-east-1",
  }:
    pkgs.mkShell {
      inherit name;
      packages = commonPackages;

      shellHook = ''
        echo "🚀 Entering ${name} environment"

        # Unset any existing AWS profile
        unset AWS_PROFILE

        # Set environment variables
        export AWS_PROFILE="${profile}"
        export AWS_REGION="${region}"
        export BALENA_CLUSTER="${cluster}"
        export BALENA_CONTEXT="${context}"
        export KUBECTL_CONTEXT="${context}"
        export BALENA_ACCOUNT="${account}"
        export BALENA_IDP_ARN="arn:aws:iam::${account}:saml-provider/Google"
        export BALENA_ROLE_ARN="arn:aws:iam::${account}:role/federated-admin"

        # Seed saml2aws's playwright-go driver so login skips the retired CDN
        # (see playwrightGoDriver above). Idempotent symlinks into the cache dir
        # that playwright-go v0.4702.0 probes on darwin (~/Library/Caches).
        _pw_driver="$HOME/Library/Caches/ms-playwright-go/1.47.2"
        mkdir -p "$_pw_driver"
        ln -sfn "${playwrightGoDriver}/package" "$_pw_driver/package"
        ln -sfn "${pkgs.nodejs_22}/bin/node" "$_pw_driver/node"

        # Create login function
        balena-login() {
          echo "🔐 Logging into ${name}..."

          # aws-saml \
          #   --profile "$AWS_PROFILE" \
          #   --region "$AWS_REGION" \
          #   --session-duration 43200 \
          #   --idp-arn "$BALENA_IDP_ARN" \
          #   --role-arn "$BALENA_ROLE_ARN"

          # Disables the use of a keychain in case it's not initialized
          export SAML2AWS_DISABLE_KEYCHAIN=false

          # Use saml2aws's bundled chromium (version-matched to its playwright-go bindings);
          # native browsers like Vivaldi/Brave crash under playwright's CDP pipe transport.
          # Env var triggers playwright.Install at login time (cmd/saml2aws/main.go:126).
          export SAML2AWS_AUTO_BROWSER_DOWNLOAD=true

          # Clear stale browser_executable_path: saml2aws gates --browser-executable-path
          # on `!= ""` (pkg/flags/flags.go), so passing "" is a no-op. Deleting the line
          # lets omitempty (pkg/cfg/cfg.go) drop the field on the next configure write.
          [ -f ~/.saml2aws ] && sed -i.bak '/^browser_executable_path/d' ~/.saml2aws \
            && rm -f ~/.saml2aws.bak

          saml2aws configure --profile default --idp-provider Browser \
            --url "https://accounts.google.com/o/saml2/initsso?idpid=C04e1utuw&spid=447476946884&forceauthn=false" \
            --browser-type chromium \
            --session-duration 43200 \
            --skip-prompt

          saml2aws login -p "$AWS_PROFILE"

          if [ $? -eq 0 ]; then
            echo "✅ AWS authentication successful"
            echo "🔄 Updating kubeconfig..."
            aws eks update-kubeconfig --name "$BALENA_CLUSTER" --profile "$AWS_PROFILE"
            kubectl config use-context "$KUBECTL_CONTEXT"
            echo "✅ Kubernetes context set to ${name}"
          else
            echo "❌ AWS authentication failed"
          fi
        }

        # get suspend resume reconcile
        function flux-next() {
          if [ -z "$1" ]; then
            echo "Available commands:"
            echo "  get - Flux get"
            echo "  suspend - Flux suspend"
            echo "  resume - Flux resume"
            echo "  reconcile - Flux reconcile"
            return 2
          fi

          if [[ $1 =~ get ]]; then
            flux --context $KUBECTL_CONTEXT get sources git flux-system
            flux --context $KUBECTL_CONTEXT get kustomizations flux-system
          else
            flux --context $KUBECTL_CONTEXT $1 source git flux-system
            flux --context $KUBECTL_CONTEXT $1 kustomization flux-system
          fi
        }

        function flux-get() {
          flux-next get
        }

        function flux-suspend() {
          flux-next suspend
        }

        function flux-resume() {
          flux-next resume
        }

        function flux-reconcile() {
          flux-next reconcile
        }

        echo ""
        echo "Available commands:"
        echo "  balena-login - Authenticate and update kubeconfig"
        echo "  kubectl - Kubernetes CLI"
        echo "  k9s - Kubernetes dashboard"
        echo "  aws - AWS CLI"
        echo "  flux - Flux CLI"
        echo "  flux-get - Flux get"
        echo "  flux-suspend - Flux suspend"
        echo "  flux-resume - Flux resume"
        echo "  flux-reconcile - Flux reconcile"
        echo ""
      '';
    };
in {
  # Playground environment
  playground = mkBalenaShell {
    name = "Balena Playground";
    profile = "balena-playground";
    context = "arn:aws:eks:us-east-1:240706700173:cluster/playground-eks-1";
    cluster = "playground-eks-1";
    account = "240706700173";
  };

  # Production environments
  production-old = mkBalenaShell {
    name = "Balena Production (Old)";
    profile = "balena-production-old";
    context = "arn:aws:eks:us-east-1:491725000532:cluster/production-eks";
    cluster = "production-eks";
    account = "491725000532";
  };

  production-us = mkBalenaShell {
    name = "Balena Production US";
    profile = "balena-production";
    context = "arn:aws:eks:us-east-1:491725000532:cluster/production-eks-us-1";
    cluster = "production-eks-us-1";
    account = "491725000532";
  };

  production-eu = mkBalenaShell {
    name = "Balena Production EU";
    profile = "balena-production-eu";
    context = "arn:aws:eks:eu-central-1:491725000532:cluster/production-eks-1";
    cluster = "production-eks-1";
    account = "491725000532";
    region = "eu-central-1";
  };

  # Staging US environment
  staging-us = mkBalenaShell {
    name = "Balena Staging US";
    profile = "balena-staging";
    context = "arn:aws:eks:us-east-1:567579488761:cluster/staging-eks-us-1";
    cluster = "staging-eks-us-1";
    account = "567579488761";
  };

  # Staging EU environment
  staging-eu = mkBalenaShell {
    name = "Balena Staging EU";
    profile = "balena-staging-eu";
    context = "arn:aws:eks:eu-central-1:567579488761:cluster/staging-eks-eu-1";
    cluster = "staging-eks-eu-1";
    account = "567579488761";
    region = "eu-central-1";
  };
}
