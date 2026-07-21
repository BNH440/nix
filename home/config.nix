{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  home.shellAliases = {
    ls = "${lib.getExe pkgs.lsd}";
    ll = "ls -l";
    la = "ls -la";
  };

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Blake Haug";
        email = "blake@blakehaug.com";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedsignersfile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      init.defaultbranch = "main";
      push.autoSetupRemote = true;
      remote.origin.fetch = "+refs/pull/*/head:refs/remotes/origin/pull/*";
      alias =
        let
          wtadd = "!${inputs.git-worktree-scripts}/wtadd.sh";
          wtclone = "!${inputs.git-worktree-scripts}/wtclone.sh";
          wtlist = "!${inputs.git-worktree-scripts}/wtlist.sh";
          wtremove = "!${inputs.git-worktree-scripts}/wtremove.sh";
        in
        {
          graph = "log --oneline --graph --decorate --all";
          cm = "commit -m";
          dlog = "-c diff.external=difft log --ext-diff";
          dl = "dlog";
          dshow = "-c diff.external=difft show --ext-diff";
          ds = "dshow";
          ddiff = "-c diff.external=difft diff";
          dd = "ddiff";
          inherit
            wtadd
            wtclone
            wtlist
            wtremove
            ;
        };
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.difftastic.enable = true;

  # Shell
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        fpath=("${pkgs.unstable.pure-prompt}/share/zsh/site-functions" $fpath)

        # show git stashes
        zstyle :prompt:pure:git:stash show yes

        # fzf-tab settings
        zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.lsd} -1 --color=always --icon=always $realpath'

        # change colors
        zstyle :prompt:pure:virtualenv color white
        zstyle :prompt:pure:git:branch color 212
        zstyle :prompt:pure:path color 141
        zstyle :prompt:pure:user color blue
        zstyle :prompt:pure:host color blue

        # activate pure
        autoload -U promptinit; promptinit
        prompt pure
      '')
      (lib.mkAfter ''
        # setup zsh keybindings
        bindkey '^[[2~' overwrite-mode
        bindkey '^[[3~' delete-char
        bindkey '^[[H' beginning-of-line
        bindkey '^[OH' beginning-of-line
        bindkey '^[[F' end-of-line
        bindkey '^[OF' end-of-line
        bindkey '^[[5~' beginning-of-buffer-or-history
        bindkey '^[[6~' end-of-buffer-or-history
      '')
    ];
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };

  # SSH config
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        addKeysToAgent = "yes";
        identityFile = "~/.ssh/id_ed25519";
      };

      "*-colmena" = {
        proxyCommand = "nc $(sed -e \"s/-colmena//\" <<< \"%h\") %p";
        forwardAgent = true;

        controlMaster = "auto";
        controlPath = "~/.ssh/control-%r@%h:%p";
        controlPersist = "5m";
      };

      "hikari" = {
        hostname = "hikari";
        forwardAgent = true;
      };
      "ito" = {
        hostname = "ito";
        forwardAgent = true;
      };
      "kako" = {
        hostname = "kako";
        forwardAgent = true;
      };
      "ronri" = {
        hostname = "ronri";
        forwardAgent = true;
      };

      # CSUA
      "soda" = {
        hostname = "soda";
        forwardAgent = true;
      };
      "tap" = {
        hostname = "tap";
        forwardAgent = true;
      };
      "latte" = {
        hostname = "latte";
        proxyJump = "soda";
        forwardAgent = true;
      };

      # OCF
      "supernova" = {
        hostname = "supernova";
        forwardAgent = true;
      };
      "koi" = {
        hostname = "koi";
        forwardAgent = true;
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
