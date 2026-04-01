{...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"

      # safe-chain: wraps npm/yarn/pnpm/bun/pip/uv with supply-chain attack protection
      [ -f "$HOME/.safe-chain/scripts/init-posix.sh" ] && source "$HOME/.safe-chain/scripts/init-posix.sh"
    '';

    # shellAliases = {
    #   k = "kubectl";

    #   urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    #   urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    # };
  };
}
