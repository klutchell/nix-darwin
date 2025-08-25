{
  config,
  lib,
  pkgs,
  ...
}: let
  balena-eks = pkgs.writeText "balena-eks" ''
    # This is a script which should be sourced

    profile="$1"

    unset AWS_PROFILE

    case $profile in
    balena-playground)
      context="arn:aws:eks:us-east-1:240706700173:cluster/playground-eks-1"
      name="playground-eks-1"
      idp_arn="arn:aws:iam::240706700173:saml-provider/Google"
      role_arn="arn:aws:iam::240706700173:role/federated-admin"
      ;;
    balena-production)
      context="arn:aws:eks:us-east-1:491725000532:cluster/production-eks"
      name="production-eks"
      idp_arn="arn:aws:iam::491725000532:saml-provider/Google"
      role_arn="arn:aws:iam::491725000532:role/federated-admin"
      ;;
    balena-staging-us)
      context="arn:aws:eks:us-east-1:567579488761:cluster/staging-eks-us-1"
      name="staging-eks-us-1"
      idp_arn="arn:aws:iam::567579488761:saml-provider/Google"
      role_arn="arn:aws:iam::567579488761:role/federated-admin"
      ;;
    balena-staging-eu)
      context="arn:aws:eks:eu-central-1:567579488761:cluster/staging-eks-eu-1"
      name="staging-eks-eu-1"
      idp_arn="arn:aws:iam::567579488761:saml-provider/Google"
      role_arn="arn:aws:iam::567579488761:role/federated-admin"
      ;;
    *)
      echo "Usage: balena-eks <balena-playground|balena-production|balena-staging>"
      return 1
      ;;
    esac

    aws-saml \
      --profile "$profile" \
      --region us-east-1 \
      --session-duration 43200 \
      --idp-arn "$idp_arn" \
      --role-arn "$role_arn"

    # # Disables the use of a keychain in case it's not initialized
    # # export SAML2AWS_DISABLE_KEYCHAIN=true

    # # export SAML2AWS_OKTA_DISABLE_SESSIONS=true
    # # export SAML2AWS_BROWSER_TYPE="chromium"

    # # Automatically downloads a compatible browser for authentication
    # export SAML2AWS_AUTO_BROWSER_DOWNLOAD=true

    # unset SAML2AWS_BROWSER_EXECUTABLE_PATH
    # # export SAML2AWS_BROWSER_EXECUTABLE_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    # export SAML2AWS_BROWSER_AUTOFILL=true

    # # prompt for the base64 SAML response on stderr, and print to stdout
    # saml2aws configure --profile default --idp-provider Browser \
    #  --url "https://accounts.google.com/o/saml2/initsso?idpid=C04e1utuw&spid=447476946884&forceauthn=false"

    export AWS_PROFILE="$profile"
    export AWS_REGION="us-east-1"

    # saml2aws login \
    #   --profile "$AWS_PROFILE" \
    #   --role "$role_arn" \
    #   --session-duration=43200 \
    #   --skip-prompt

    aws eks update-kubeconfig --name "$name" --profile "$AWS_PROFILE"
    kubectl config use-context "$context"
    return
  '';
in {
  home.packages = with pkgs; [
    awscli2
    # aws-google-auth
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
            sha256 = "sha256-rQt985S0pYxKL7Z6vrQr/DhhVs6NUcdzL67N5kXQ1Q8="; # Replace with the correct hash
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

  programs.zsh.shellAliases.playground-eks = "source ${balena-eks} balena-playground";
  programs.zsh.shellAliases.production-eks = "source ${balena-eks} balena-production";
  programs.zsh.shellAliases.staging-eks = "source ${balena-eks} balena-staging-us";
  programs.zsh.shellAliases.staging-eks-eu = "source ${balena-eks} balena-staging-eu";

  programs.bash.shellAliases.playground-eks = "source ${balena-eks} balena-playground";
  programs.bash.shellAliases.production-eks = "source ${balena-eks} balena-production";
  programs.bash.shellAliases.staging-eks = "source ${balena-eks} balena-staging-us";
  programs.bash.shellAliases.staging-eks-eu = "source ${balena-eks} balena-staging-eu";
}
