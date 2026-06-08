{
  self,
  pkgs,
  inputs,
  config,
  ...
}:

let
  openssh-sk-standalone = import ./pkgs/openssh-sk-standalone.nix { inherit pkgs; };
in
{
  imports = [
    ../../modules/secrets.nix
    ../../modules/pkgs-config.nix
  ];

  users.users.blakeh = {
    name = "blakeh";
    home = "/Users/blakeh";
  };

  programs.zsh.enable = true;

  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # Nix related
    nh
    devenv

    # Graphical
    aseprite
    cinny-desktop
    aerospace
    prismlauncher
    postman
    obsidian
    notion-app
    mos
    halloy
    google-chrome
    jetbrains.pycharm
    jetbrains.datagrip
    jetbrains.rust-rover

    # CLI
    imagemagick
    avrdude
    epubcheck
    prettier
    pandoc
    darwin.lsusb
    coreutils-prefixed # replaces homebrew `coreutils`
    neovim

    # Cache
    inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3

    # enable openssh
    openssh
  ];

  system.primaryUser = "blakeh";

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraEnv = {
        "HOMEBREW_ASK" = "0";
      };
    };
    global.autoUpdate = false;
    taps = [
      "lajosdeme/utils"
    ];
    brews = [
      "lajosdeme/utils/xcclear"
    ];
    casks = [
      "notunes"
    ];
  };

  # allow touch-id sudo
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  # setup ssh agent
  launchd.user.agents.ssh-agent = {
    command = "${pkgs.openssh}/bin/ssh-agent -D -a /tmp/ssh-agent.socket -P ${openssh-sk-standalone}/lib/sk-libfido2.dylib";
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
    serviceConfig.EnvironmentVariables = {
      SSH_ASKPASS = "/etc/ssh-askpass";
      SSH_ASKPASS_REQUIRE = "prefer";
      DISPLAY = ":0";
    };
  };
  environment.variables.SSH_AUTH_SOCK = "/tmp/ssh-agent.socket";

  # add yubikey
  environment.etc."ssh-askpass".source = pkgs.writeScript "ssh-askpass" ''
    #!/bin/bash
    if echo "$1" | grep -q "PIN"; then
      /usr/bin/osascript -e 'display dialog "'"$1"'" default answer "" with hidden answer' -e 'text returned of result'
    else
      echo ""
    fi
  '';

  # setup nix helper
  environment.variables.NH_FLAKE = "/Users/blakeh/.nixos";

  environment.variables.EDITOR = "vim";
  environment.variables.VISUAL = "vim";

  programs.nix-index-database.comma.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Binary cache
  nix.settings.substituters = [ "https://nixcache.blakehaug.com" ];
  nix.settings.trusted-public-keys = [
    "nixcache.blakehaug.com-1:gCvj6d/XaSiX6YpelqVPX/kCZAfvAraN8BhtN22TG50="
  ];

  # enable linux-builder
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 2;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 4;
      };
    };
  };
  nix.settings.trusted-users = [ "blakeh" ];

  networking.hostName = "hikari";
  age.secrets.niks3-auth-token = {
    owner = "blakeh";
    group = "staff";
    rekeyFile = ../../secrets/niks3-auth-token.age;
  };

  environment.variables = {
    NIKS3_SERVER_URL = "https://nixcache.blakehaug.com";
    NIKS3_AUTH_TOKEN_FILE = config.age.secrets.niks3-auth-token.path;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # auto garbage collect nix-store
  nix.gc = {
    automatic = true;
    interval = {
      Hour = 3;
      Minute = 15;
      Weekday = 7;
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
