{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "safe-chain";
  version = "1.5.3";

  dontStrip = true;
  dontUnpack = true;

  src = pkgs.fetchurl {
    url = "https://github.com/AikidoSec/safe-chain/releases/download/${version}/safe-chain-macos-arm64";
    sha256 = "sha256-5L723GUHEYma1UtQKXNrlKQRkMw209Cw+HRsMVxXvLk=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/safe-chain
    chmod +x $out/bin/safe-chain
  '';

  meta = with pkgs.lib; {
    description = "Protect against malicious code installed via npm, yarn, pnpm, npx, and pnpx";
    homepage = "https://github.com/AikidoSec/safe-chain";
    license = licenses.asl20;
    platforms = ["aarch64-darwin"];
    mainProgram = "safe-chain";
  };
}
