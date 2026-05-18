{ ... }:

{
  imports = [
    ./packages.nix
    ./services.nix
    ./system.nix
    ./secrets.nix
    ./stats.nix
  ];
}
