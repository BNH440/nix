{
  config,
  pkgs,
  inputs,
  pubkeys,
  yubikeys,
  self,
  ...
}:

{
  imports = [ ];

  # embed git commit in nixos-version
  system.configurationRevision = self.rev or self.dirtyRev or "dirty";
  system.nixos.label = "git-${self.shortRev or self.dirtyShortRev or "dirty"}";

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Binary cache
  nix.settings.substituters = [ "https://nixcache.blakehaug.com" ];
  nix.settings.trusted-public-keys = [
    "nixcache.blakehaug.com-1:gCvj6d/XaSiX6YpelqVPX/kCZAfvAraN8BhtN22TG50="
  ];

  age.secrets.niks3-auth-token.rekeyFile = ../secrets/niks3-auth-token.age;

  services.niks3-auto-upload = {
    enable = true;
    package = inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3-hook;
    serverUrl = "https://nixcache.blakehaug.com";
    authTokenFile = config.age.secrets.niks3-auth-token.path;
  };
  environment.sessionVariables = {
    NIKS3_SERVER_URL = "https://nixcache.blakehaug.com";
    NIKS3_AUTH_TOKEN_FILE = config.age.secrets.niks3-auth-token.path;
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Setup shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  age.secrets.blakeh-password-hash.rekeyFile = ../secrets/blakeh-password-hash.age;

  users.mutableUsers = false;
  users.users.blakeh = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "dialout"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = pubkeys;
    hashedPasswordFile = config.age.secrets.blakeh-password-hash.path;
  };

  users.groups.deploy-user = { };
  nix.settings.trusted-users = [ "deploy-user" ];

  users.users.deploy-user = {
    isNormalUser = true;
    group = "deploy-user";
    createHome = false;
    home = "/var/empty";
    openssh.authorizedKeys.keys = yubikeys;
  };

  # fix colmena apply needing interactive sudo password entry
  security.sudo.extraRules = [
    {
      users = [ "deploy-user" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-store --no-gc-warning --realise /nix/store/*";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set /nix/store/*";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*/bin/switch-to-configuration *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
