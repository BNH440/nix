{
  self,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  openssh-sk-standalone = import ./pkgs/openssh-sk-standalone.nix { inherit pkgs; };
in
{
  imports = [ ];

  users.users.blakeh = {
    name = "blakeh";
    home = "/Users/blakeh";
  };

  programs.zsh.enable = true;

  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # Nix related
    nh
    nil
    nixd
    devenv

    # Graphical
    aseprite
    cinny-desktop

    # Misc
    mosh

    # Cache
    inputs.attic.packages.${pkgs.system}.attic-client

    # enable openssh
    openssh
  ];

  system.primaryUser = "blakeh";

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
  nix.settings.substituters = [ "https://nixcache.blakehaug.com/main" ];
  nix.settings.trusted-public-keys = [ "main:gMJfiUKchtX1jmnXVUA3t54OMNLfCsTrj2nytssdU7A=" ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
