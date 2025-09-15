{pkgs}: let
  # Common packages for all environments
  commonPackages = with pkgs; [
    awscli2
    k9s
    kubectl
    kubeseal
    saml2aws
    fluxcd
    (python3.withPackages (p:
      with p; [
        (buildPythonPackage rec {
          pname = "awscli-saml";
          version = "2.0.2";
          src = fetchPypi {
            inherit pname version;
            sha256 = "sha256-rQt985S0pYxKL7Z6vrQr/DhhVs6NUcdzL67N5kXQ1Q8=";
          };
          propagatedBuildInputs = [
            boto3
            botocore
            lxml
            requests
            pip
          ];
        })
      ]))
  ];

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
        export BALENA_ACCOUNT="${account}"
        export BALENA_IDP_ARN="arn:aws:iam::${account}:saml-provider/Google"
        export BALENA_ROLE_ARN="arn:aws:iam::${account}:role/federated-admin"

        # Create login function
        balena-login() {
          echo "🔐 Logging into ${name}..."
          aws-saml \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --session-duration 43200 \
            --idp-arn "$BALENA_IDP_ARN" \
            --role-arn "$BALENA_ROLE_ARN"

          if [ $? -eq 0 ]; then
            echo "✅ AWS authentication successful"
            echo "🔄 Updating kubeconfig..."
            aws eks update-kubeconfig --name "$BALENA_CLUSTER" --profile "$AWS_PROFILE"
            kubectl config use-context "$BALENA_CONTEXT"
            echo "✅ Kubernetes context set to ${name}"
            echo ""
            echo "Available commands:"
            echo "  kubectl - Kubernetes CLI"
            echo "  k9s - Kubernetes dashboard"
            echo "  aws - AWS CLI"
            echo ""
          else
            echo "❌ AWS authentication failed"
          fi
        }

        echo "Run 'balena-login' to authenticate and configure kubectl"
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
