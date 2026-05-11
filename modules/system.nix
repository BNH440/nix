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

  age.secrets.attic-auth-token.rekeyFile = ../secrets/attic-auth-token.age;

  systemd.services.attic-watch-store =
    let
      attic-client = inputs.attic.packages.${pkgs.system}.attic-client;
    in
    {
      description = "Attic watch-store";
      after = [
        "network-online.target"
        "agenix.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.writeShellScript "attic-login" ''
          ${attic-client}/bin/attic login --set-default nixcache https://nixcache.blakehaug.com "$(cat ${config.age.secrets.attic-auth-token.path})"
        ''}";
        ExecStart = "${attic-client}/bin/attic watch-store main";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

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

  # CVE-2026-31431 & CVE-2026-43284
  boot.blacklistedKernelModules = [
    "algif_aead"
    "esp4"
    "esp6"
    "rxrpc"
  ];
}
