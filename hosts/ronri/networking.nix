{
  ...
}:

{
  imports = [ ];

  networking.hostName = "ronri"; # Define your hostname.

  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "none";
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.nameservers = [
    "2607:f140:8801::1:22"
    "169.229.226.22"
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
  networking.domain = "ocf.berkeley.edu";
  networking.search = [ "ocf.berkeley.edu" ];

  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "169.229.226.254";
      prefixLength = 24;
    }
  ];
  networking.interfaces.ens18.ipv6.addresses = [
    {
      address = "2607:f140:8801::1:254";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "169.229.226.1";

  # Open ports
  # networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ 25565 ];
  # networking.firewall.allowedTCPPorts = [ 8888 ];
}
