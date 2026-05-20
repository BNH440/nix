{
  ...
}:

{
  imports = [
    ./backup.nix
    ./dynmap.nix
  ];

  # Minecraft Ports
  networking.firewall.allowedTCPPorts = [ 25437 ];
  networking.firewall.allowedUDPPorts = [ 25437 ];
}
