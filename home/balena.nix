{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    awscli2
    aws-google-auth
    k9s
    kubectl
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
          ];
        })
      ]))

    (writeShellScriptBin "balena-aws-production" ''
      set -e
      unset AWS_PROFILE

      # aws-google-auth \
      #   -p balena-production \
      #   -r arn:aws:iam::491725000532:role/federated-admin \
      #   -R us-east-1 -I C04e1utuw -S 447476946884 \
      #   -k --bg-response None -l debug

      aws-saml \
        --profile balena-production \
        --region us-east-1 \
        --session-duration 43200 \
        --idp-arn arn:aws:iam::491725000532:saml-provider/Google \
        --role-arn arn:aws:iam::491725000532:role/federated-admin

      export AWS_PROFILE="balena-production"

      aws --profile balena-production eks --region us-east-1 update-kubeconfig \
        --name production-eks --alias production-eks

      kubectl config use-context production-eks

      echo "Environment set to balena-production!"
    '')

    (writeShellScriptBin "balena-aws-staging" ''
      set -e
      unset AWS_PROFILE

      # aws-google-auth \
      #   -p balena-staging \
      #   -r arn:aws:iam::567579488761:role/federated-admin \
      #   -R us-east-1 -I C04e1utuw -S 447476946884 \
      #   -k --bg-response None -l debug

      aws-saml \
        --profile balena-staging \
        --region us-east-1 \
        --session-duration 43200 \
        --idp-arn arn:aws:iam::567579488761:saml-provider/Google \
        --role-arn arn:aws:iam::567579488761:role/federated-admin

      export AWS_PROFILE="balena-staging"

      aws --profile balena-staging eks --region us-east-1 update-kubeconfig \
        --name staging-eks --alias staging-eks

      kubectl config use-context staging-eks

      echo "Environment set to balena-staging!"
    '')

    (writeShellScriptBin "balena-aws-playground" ''
      set -e
      unset AWS_PROFILE

      # aws-google-auth \
      #   -p balena-playground \
      #   -r arn:aws:iam::240706700173:role/federated-admin \
      #   -R us-east-1 -I C04e1utuw -S 447476946884 \
      #   -k --bg-response None -l debug

      aws-saml \
        --profile balena-playground \
        --region us-east-1 \
        --session-duration 43200 \
        --idp-arn arn:aws:iam::240706700173:saml-provider/Google \
        --role-arn arn:aws:iam::240706700173:role/federated-admin

      export AWS_PROFILE="balena-playground"

      aws --profile balena-playground eks --region us-east-1 update-kubeconfig \
        --name playground-eks --alias playground-eks

      kubectl config use-context playground-eks

      echo "Environment set to balena-playground!"
    '')
  ];
}
