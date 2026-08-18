{
  ...
}:

{
  imports = [ ];

  networking.hostName = "kako";
  networking.networkmanager.enable = true;

  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--exit-node-allow-lan-access"
  ];
}
