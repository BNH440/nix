{
  ...
}:

{
  imports = [
    ./packages.nix
    ./services.nix
    ./system.nix
    ./secrets.nix
    ./stats/default.nix
    ./cache/default.nix
    ./web.nix
    ./pkgs-config.nix
    ./oom.nix
    ./direnv.nix
  ];
}
