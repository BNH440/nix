{
  config,
  lib,
  pkgs,
  inputs,
  pubkeys,
  ...
}:

{
  imports = [ ];

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Binary cache
  nix.settings.substituters = [ "https://nixcache.blakehaug.com/main" ];
  nix.settings.trusted-public-keys = [ "main:gMJfiUKchtX1jmnXVUA3t54OMNLfCsTrj2nytssdU7A=" ];

  # Attic cache push credentials
  age.secrets.attic-auth-token.rekeyFile = ../secrets/attic-auth-token.age;
  nix.settings.post-build-hook =
    let
      upload-script = pkgs.writeScript "attic-upload" ''
        #!/bin/sh
        set -f
        ${inputs.attic.packages.${pkgs.system}.attic-client}/bin/attic push main $OUT_PATHS || true
      '';
    in
    "${upload-script}";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Setup shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  users.users.blakeh = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "dialout"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = pubkeys;
  };

  # fix colmena apply needing interactive sudo password entry
  security.sudo.extraRules = [
    {
      users = [ "blakeh" ];
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
