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
    balena-staging)
      context="arn:aws:eks:us-east-1:567579488761:cluster/staging-eks"
      name="staging-eks"
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

    export AWS_PROFILE="$profile"
    aws eks update-kubeconfig --name "$name"
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
    # saml2aws
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
  programs.zsh.shellAliases.staging-eks = "source ${balena-eks} balena-staging";

  programs.bash.shellAliases.playground-eks = "source ${balena-eks} balena-playground";
  programs.bash.shellAliases.production-eks = "source ${balena-eks} balena-production";
  programs.bash.shellAliases.staging-eks = "source ${balena-eks} balena-staging";
}
