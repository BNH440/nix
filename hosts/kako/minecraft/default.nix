{
  ...
}:

{
  imports = [
    ./backup.nix
    ./dynmap.nix
  ];

  # Minecraft Ports
  networking.firewall.allowedTCPPorts = [ 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];
}
