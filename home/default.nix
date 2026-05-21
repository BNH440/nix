{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [ ];

  home.packages = with pkgs; [
    bat
    lsd
    ripgrep-all
    aria2
    btop
    croc
    diff-so-fancy
    dos2unix
    exiftool
    fastfetch
    ffmpeg
    gh
    glow
    jq
    iperf
    lazygit
    pre-commit
    qrencode
    rclone
    restic
    rhash
    speedtest-cli
    pay-respects
    wakeonlan
    yubikey-manager
    yt-dlp
    claude-code
    inputs.tsexit.packages.${pkgs.system}.default
    teleport
    ncdu
  ];

  home.shellAliases = {
    ls = "lsd";
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
      core.pager = "diff-so-fancy | less --tabs=4 -RF";
      interactive.diffFilter = "diff-so-fancy --patch";
    };
  };

  programs.zsh.enable = true;
  programs.zsh.defaultKeymap = "emacs";
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.mkMerge [
      (lib.importTOML ./starship-nerd-font-symbols.toml)
      (lib.importTOML ./starship.toml)
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # SSH config
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "hikari" = {
        HostName = "hikari";
        ForwardAgent = true;
      };
      "ito" = {
        HostName = "ito";
        ForwardAgent = true;
      };
      "kako" = {
        HostName = "kako";
        ForwardAgent = true;
      };
      "ronri" = {
        HostName = "ronri";
        ForwardAgent = true;
      };

      # CSUA
      "soda" = {
        HostName = "soda";
        ForwardAgent = true;
      };
      "tap" = {
        HostName = "tap";
        ForwardAgent = true;
      };
      "latte" = {
        HostName = "latte";
        ProxyJump = "soda";
        ForwardAgent = true;
      };

      # OCF
      "supernova" = {
        HostName = "supernova";
        ForwardAgent = true;
      };
      "koi" = {
        HostName = "koi";
        ForwardAgent = true;
      };
    };
    extraConfig = ''
      # Begin CS161 instructional machine config
      Host s330-? s330-??
        HostName %h.cs.berkeley.edu
        ProxyJump %r@instgw.eecs.berkeley.edu
        ForwardAgent yes
      Match Host *.cs.berkeley.edu
        Port 22
        User cs161-amk
        ServerAliveInterval 60
        ForwardAgent yes
      # End CS161 instructional machine config
    '';
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
