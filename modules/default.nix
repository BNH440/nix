{
  ...
}:

{
  imports = [
    ./packages.nix
    ./services.nix
    ./system.nix
    ./secrets.nix
    ./stats/stats.nix
    ./stats/grafana.nix
    ./web.nix
    ./pkgs-config.nix
    ./oom.nix
    ./direnv.nix
  ];
}
