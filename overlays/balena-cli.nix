final: prev: {
  balena-cli = prev.balena-cli.overrideAttrs (finalAttrs: prevAttrs: {
    version = "21.1.9";
    src = final.fetchFromGitHub {
      owner = "balena-io";
      repo = "balena-cli";
      rev = "v${finalAttrs.version}";
      hash = "sha256-oeOhE4cgN/u9zLEXoiMbbE+onNJvrX8wNjoydh20Wdk=";
    };
    npmDepsHash = final.lib.fakeHash;
  });
}
