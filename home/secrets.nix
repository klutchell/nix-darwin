{ config, agenix, ... }:

{
  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/id_ed25519"
  ];

  age.secrets."github-pat" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.github_pat";
    file =  "../secrets/github-pat.age";
    mode = "600";
    owner = "${config.home.username}";
    group = "users";
  };

  age.secrets."openai-pat" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.openai_pat";
    file =  "../secrets/openai-pat.age";
    mode = "600";
    owner = "${config.home.username}";
    group = "users";
  };

  # age.secrets."github-ssh-key" = {
  #   symlink = false;
  #   path = "${config.home.homeDirectory}/.ssh/id_github";
  #   file =  "../secrets/github-ssh-key.age";
  #   mode = "600";
  #   owner = "${config.home.username}";
  #   group = "wheel";
  # };

  # age.secrets."github-signing-key" = {
  #   symlink = false;
  #   path = "${config.home.homeDirectory}/.ssh/pgp_github.key";
  #   file =  "../secrets/github-signing-key.age";
  #   mode = "600";
  #   owner = "${config.home.username}";
  #   group = "wheel";
  # };
}
