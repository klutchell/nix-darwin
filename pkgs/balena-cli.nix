# https://github.com/pipex/nixpkgs/blob/macbook/balena-cli.nix
{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "balena-cli";
  version = "18.2.32";

  src = pkgs.fetchzip {
    url = "https://github.com/balena-io/balena-cli/releases/download/v${version}/balena-cli-v${version}-macOS-arm64-standalone.zip";
    sha256 = "sha256-tWt7yvln9CXphi8yjKmxA2HscV82gJlu+2KSaOnXpug=";
    # url = "https://ab77.s3.amazonaws.com/balena-cli-v18.1.0-macOS-arm64-standalone.zip";
    # sha256 = "sha256-/Kvp81qOYzpTkWECePg+MM7EW4FxqEKqimdVqPlyAsE=";
  };

  installPhase = ''
    mkdir -p $out/balena-cli
    mkdir -p $out/bin
    cp -r * $out/balena-cli
    ln -s $out/balena-cli/balena $out/bin/balena
  '';

  meta = with pkgs.lib; {
    description = "The official balena CLI tool";
    homepage = "https://github.com/balena-io/balena-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    platforms = platforms.darwin;
  };
}
