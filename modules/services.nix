{
  lib,
  pkgs,
  ...
}:

{
  imports = [ ];

  programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Require pubkey auth
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # restrict ssh to tailscale only
  services.openssh.openFirewall = lib.mkForce false;
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];

  # Tailscale config
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # add tailscale CLI and podman config
  environment.systemPackages = with pkgs; [
    tailscale

    podman-compose
    slirp4netns
    fuse-overlayfs
  ];

  # Docker config
  virtualisation = {
    containers = {
      enable = true;
      registries.search = [ "docker.io" ];
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

    };
  };
  users.users.blakeh = {
    extraGroups = [ "podman" ];
    linger = true;
  };
  systemd.user.services.podman-restart = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      RemainAfterExit = true;
    };
  };

  services.fail2ban.enable = true;
  networking.firewall = {
    logRefusedConnections = false;
    logRefusedPackets = false;
  };
}
