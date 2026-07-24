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

  # Tailscale config
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--accept-routes" # ronri has routes configured in ronri/networking.nix
      "--advertise-exit-node"
      "--exit-node-allow-lan-access"
      "--ssh"
    ];
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
