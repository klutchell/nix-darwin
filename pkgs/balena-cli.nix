# based on https://github.com/pipex/nixpkgs/blob/macbook/balena-cli.nix
# alternative to https://github.com/NixOS/nixpkgs/blob/release-24.11/pkgs/by-name/ba/balena-cli/package.nix
{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "balena-cli";
  version = "23.2.30";

  src = pkgs.fetchzip {
    url = "https://github.com/balena-io/balena-cli/releases/download/v${version}/balena-cli-v${version}-macOS-arm64-standalone.tar.gz";
    sha256 = "sha256-jfM55sIFmvzmxB78SmaQyxPikPQ5L3vymg0PXTrkolY=";
  };

  installPhase = ''
    mkdir -p $out/libexec/balena-cli
    mkdir -p $out/bin
    cp -r * $out/libexec/balena-cli
    ln -s $out/libexec/balena-cli/bin/balena $out/bin/balena
  '';

  meta = with pkgs.lib; {
    description = "Command line interface for balenaCloud or openBalena";
    longDescription = ''
      The balena CLI is a Command Line Interface for balenaCloud or openBalena. It is a software
      tool available for Windows, macOS and Linux, used through a command prompt / terminal window.
      It can be used interactively or invoked in scripts. The balena CLI builds on the balena API
      and the balena SDK, and can also be directly imported in Node.js applications.
    '';
    homepage = "https://github.com/balena-io/balena-cli";
    changelog = "https://github.com/balena-io/balena-cli/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    platforms = platforms.darwin;
    mainProgram = "balena";
  };
}
