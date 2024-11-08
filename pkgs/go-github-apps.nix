{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "go-github-apps";
  version = "0.2.1";

  src = pkgs.fetchurl {
    url = "https://github.com/nabeken/go-github-apps/releases/download/v${version}/go-github-apps_${version}_darwin_arm64.tar.gz";
    sha256 = "sha256-GMSzj5ulVIkrIm35fMONZcBjBvT0OMeVGq5djua/GHo=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    install -m755 go-github-apps $out/bin/go-github-apps
  '';

  meta = with pkgs.lib; {
    description = "A tiny command-line utility to retrieve Github Apps Installation Token";
    homepage = "https://github.com/nabeken/go-github-apps";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
