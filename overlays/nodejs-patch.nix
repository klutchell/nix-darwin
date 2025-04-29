# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/400290 is merged to release-24.11
# See: https://github.com/NixOS/nixpkgs/issues/402079
final: prev: {
  nodejs_20 = prev.nodejs_20.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch2 {
          url = "https://github.com/nodejs/node/commit/33f6e1ea296cd20366ab94e666b03899a081af94.patch?full_index=1";
          hash = "sha256-aVBMcQlhQeviUQpMIfC988jjDB2BgYzlMYsq+w16mzU=";
        })
      ];
  });
}
