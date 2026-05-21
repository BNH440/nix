{
  lib,
  ...
}:

{
  imports = [ ];

  networking.hostName = "ito";
  networking.networkmanager.enable = true;

  # required for zfs
  networking.hostId = "e8ae694f";

  services.fail2ban.enable = lib.mkForce false;
}
