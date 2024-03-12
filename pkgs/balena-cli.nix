# https://github.com/pipex/nixpkgs/blob/macbook/balena-cli.nix
{
  pkgs ? import <nixpkgs> {},
  version,
  hash,
}:
pkgs.stdenv.mkDerivation rec {
  name = "balena-cli";

  src = pkgs.fetchzip {
    url = "https://github.com/balena-io/balena-cli/releases/download/v${version}/balena-cli-v${version}-macOS-arm64-standalone.zip";
    sha256 = "${hash}";
    # url = "https://ab77.s3.amazonaws.com/balena-cli-v18.1.0-macOS-arm64-standalone.zip";
    # sha256 = "sha256-/Kvp81qOYzpTkWECePg+MM7EW4FxqEKqimdVqPlyAsE=";
  };

  installPhase = ''
    mkdir -p $out/balena-cli
    mkdir -p $out/bin
    cp -r * $out/balena-cli
    ln -s $out/balena-cli/balena $out/bin/balena
  '';
}
