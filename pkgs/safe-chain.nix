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
    mkdir -p $out/libexec $out/bin
    cp $src $out/libexec/safe-chain
    chmod +x $out/libexec/safe-chain

    cat > $out/bin/safe-chain << 'WRAPPER'
    #!/usr/bin/env bash
    # The pkg-bundled binary resolves its cert dir relative to its own
    # location (execPath/../certs) and tries to mkdir it on startup,
    # which fails under the read-only nix store. Stage a copy in the
    # user's cache the first time we run a given version, then exec it
    # from there so it has a writable prefix. Also maintain a 'current'
    # symlink so shell init can source ~/.cache/safe-chain/current/
    # scripts/init-posix.sh without baking in the version.
    cache_root="$HOME/.cache/safe-chain"
    cache="$cache_root/@VERSION@"
    if [ ! -x "$cache/bin/safe-chain" ]; then
      mkdir -p "$cache/bin"
      cp @OUT@/libexec/safe-chain "$cache/bin/safe-chain"
      chmod +x "$cache/bin/safe-chain"
    fi
    ln -sfn "@VERSION@" "$cache_root/current"
    exec "$cache/bin/safe-chain" "$@"
    WRAPPER

    substituteInPlace $out/bin/safe-chain \
      --replace '@VERSION@' '${version}' \
      --replace '@OUT@' "$out"

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
