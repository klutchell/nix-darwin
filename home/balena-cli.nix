# https://github.com/pipex/nixpkgs/blob/macbook/balena-cli.nix
{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "balena-cli";
  version = "17.1.5";
  hash = "sha256-wq4ceJ9QfcL/GsglboLVw+C4/bJfQTPm5YXusQVge+Y=";

  src = pkgs.fetchzip {
    url = "https://github.com/balena-io/balena-cli/releases/download/v${version}/balena-cli-v${version}-macOS-x64-standalone.zip";
    sha256 = "${hash}";
  };

  installPhase = ''
    mkdir -p $out/balena-cli
    mkdir -p $out/bin 
    cp -r * $out/balena-cli
    ln -s $out/balena-cli/balena $out/bin/balena 
  '';
}
