# https://github.com/ryantm/agenix#tutorial
let
  kyle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpysU/UVQlBFMYeaFtz2ZeuuGcbM7OUE3EMC2DgyEiv";
  # user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI6jSq53F/3hEmSs+oq9L4TwOo1PrDMAgcA1uo1CCV/";
  users = [ kyle ];
  # users = [ user1 user2 ];

  mercury = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPS9GCxP7AI99Uxud3L4IYFSjB1VJAHT9w5XBjH96ITv";
  # system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  systems = [ mercury ];
  # systems = [ system1 system2 ];
in
{
  # "secret1.age".publicKeys = [ user1 system1 ];
  # "secret2.age".publicKeys = users ++ systems;

  "github-pat.age".publicKeys = users ++ systems;
  "openai-pat.age".publicKeys = users ++ systems;
}
