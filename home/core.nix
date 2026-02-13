{
  pkgs,
  config,
  ...
}: {
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    coreutils # GNU core utilities
    fd # simple, fast alternative to find
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    gnugrep # GNU grep, egrep and fgrep

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    tio # simple TTY terminal I/O application

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    # caddy
    gnupg

    # productivity
    glow # markdown previewer in terminal

    podman # Program for managing pods, containers and container images
    podman-compose # Implementation of docker-compose with podman backend
    buildah # Tool which facilitates building OCI images

    git-crypt # transparent file encryption in git
    git-secret # store private data in git using GPG encryption
    hadolint # Dockerfile linter, validate inline bash scripts
    htop # interactive process viewer
    neofetch # A CLI system information tool written in BASH that supports displaying images.
    nodejs_24 # A JavaScript runtime built on Chrome's V8 JavaScript engine
    shellcheck # shell script analysis tool
    shfmt # A shell parser, formatter, and interpreter (POSIX/Bash/mksh)
    # yadm # Yet Another Dotfiles Manager
    bun # Bun is a fast, modern package manager for JavaScript and TypeScript.

    arkade # Kubernetes apps installer
    alejandra # The Uncompromising Nix Code Formatter

    # bitwarden-cli # The command line vault (Windows, macOS, & Linux).

    actionlint # GitHub Actions linter
    pre-commit # A framework for managing and maintaining multi-language pre-commit hooks.

    (callPackage ../pkgs/balena-cli.nix {})

    # (callPackage ../pkgs/go-github-apps.nix {})

    skopeo # A command line utility for various operations on container images and image repositories

    kubectl # Kubernetes command-line tool
    k9s # Kubernetes CLI to manage and view your clusters in a terminal UI

    uv # An extremely fast Python package and project manager, written in Rust
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      gitCredentialHelper.enable = true;
    };

    autojump = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    gpg = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    go = {
      enable = true;
      env = {
        GOPATH = [
          "${config.home.homeDirectory}/go"
        ];
        GOBIN = "${config.home.homeDirectory}/go/bin";
      };
    };

    # https://nix-community.github.io/home-manager/options.html#opt-programs.git.delta.enable
    # https://github.com/dandavison/delta
    delta = {
      enable = true;
      enableGitIntegration = true;
      # options = {
      #   features = "side-by-side";
      # };
    };

    # Terminal Emulator
    # https://github.com/ghostty-terminal/ghostty
    # NOTE: ghostty nixpkg is Linux-only; installed via homebrew cask instead
    # ghostty = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    #   settings = {
    #     macos-option-as-alt = true;
    #   };
    # };

    # Terminal UI for git
    # https://github.com/jesseduffield/lazygit
    lazygit = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        git.commit.signOff = true;
        customCommands = [
          {
            key = "<c-a>";
            context = "files";
            description = "AI commit message";
            command = ''git commit -s -F <(claude -p "Generate a commit message for the staged changes. Use conventional commit style. Output ONLY the raw commit message, nothing else — no markdown fences, no explanation.")'';
            output = "log";
          }
        ];
      };
    };

    # Terminal File Manager
    # https://github.com/sxyazi/yazi
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings.manager.ratio = [ 1 1 6 ];
    };

    # Smarter cd — tracks frecency for zoxide-powered tools like zsm
    # https://github.com/ajeetdsouza/zoxide
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    # Terminal Workspace with Batteries Included
    # https://zellij.dev/
    zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      attachExistingSession = true;
      exitShellOnExit = true;
      extraConfig = builtins.readFile ./zellij.kdl;
      # layouts = {
      #   dev = {
      #     layout = {
      #       _children = [
      #         {
      #           default_tab_template = {
      #             _children = [
      #               {
      #                 pane = {
      #                   size = 1;
      #                   borderless = true;
      #                   plugin = {
      #                     location = "zellij:tab-bar";
      #                   };
      #                 };
      #               }
      #               {"children" = {};}
      #               {
      #                 pane = {
      #                   size = 2;
      #                   borderless = true;
      #                   plugin = {
      #                     location = "zellij:status-bar";
      #                   };
      #                 };
      #               }
      #             ];
      #           };
      #         }
      #         {
      #           tab = {
      #             _props = {
      #               name = "Project";
      #               focus = true;
      #             };
      #             _children = [
      #               {
      #                 pane = {
      #                   command = "nvim";
      #                 };
      #               }
      #             ];
      #           };
      #         }
      #         {
      #           tab = {
      #             _props = {
      #               name = "Git";
      #             };
      #             _children = [
      #               {
      #                 pane = {
      #                   command = "lazygit";
      #                 };
      #               }
      #             ];
      #           };
      #         }
      #         {
      #           tab = {
      #             _props = {
      #               name = "Files";
      #             };
      #             _children = [
      #               {
      #                 pane = {
      #                   command = "yazi";
      #                 };
      #               }
      #             ];
      #           };
      #         }
      #         {
      #           tab = {
      #             _props = {
      #               name = "Shell";
      #             };
      #             _children = [
      #               {
      #                 pane = {
      #                   command = "zsh";
      #                 };
      #               }
      #             ];
      #           };
      #         }
      #       ];
      #     };
      #   };
      # };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      # Configure gpg-agent to cache keys for 24 hours
      extraConfig = ''
        default-cache-ttl 86400
        max-cache-ttl 86400
      '';
    };
  };

  home.file.".config/zellij/plugins/zsm.wasm".source = pkgs.fetchurl {
    url = "https://github.com/liam-mackie/zsm/releases/download/v0.4.1/zsm.wasm";
    sha256 = "026bpn09r6rsjsvrd21l0l4jzsq0cggbn9dgvammjh87q7s9yl7r";
  };

  home.file.".config/ghostty/config".text = ''
    macos-option-as-alt = true
  '';

  home.file.".claude/CLAUDE.md".source = ./claude-code.md;

  home.file.".config/worktrunk/config.toml".text = ''
    # Worktree path: sibling directory with @ separator
    # e.g., ~/src/org/repo@feature-branch
    worktree-path = "{{ repo_path }}/../{{ repo }}@{{ branch | sanitize }}"
  '';

  home.file.".prettierrc".text = ''
    {
      "proseWrap": "always",
      "printWidth": 80
    }
  '';

  home.file.".config/zellij/layouts/dev.kdl".text = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }

        tab focus=true {
            pane split_direction="vertical" {
                pane size="50%" {
                    command "claude"
                    name "Claude Code"
                }
                pane size="50%" {
                    command "lazygit"
                    name "lazygit"
                }
            }
            pane split_direction="vertical" size="50%" {
                pane size="50%" {
                    command "yazi"
                    name "yazi"
                }
                pane size="50%" {
                    name "terminal"
                }
            }
        }
    }
  '';
}
