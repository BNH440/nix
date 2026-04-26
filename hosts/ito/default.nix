{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./graphical.nix
    ./disks.nix
    ./nvidia.nix
    ./input.nix
    ./audio.nix
    ./boot.nix
    ./tablet.nix
    ../../modules/default.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "data" ]; # auto import these pools on boot
  age.secrets.zfs-data-key = {
    rekeyFile = ../../secrets/zfs-data.key.age;
    path = "/etc/zfs/data.key";
    mode = "0400";
    owner = "root";
  };
  systemd.services."zfs-import-data" = {
    after = [ "agenix.service" ];
    wants = [ "agenix.service" ];
  };

  # yubikey support
  services.pcscd.enable = true;

  # openrgb setup
  services.hardware.openrgb.enable = true;
  environment.systemPackages = with pkgs; [
    openrgb
  ];

  # allow unfree packages for nvidia
  nixpkgs.config.allowUnfree = true;

  # fix crashes?
  boot.kernelParams = [
    "processor.max_cstate=1"
    "idle=nomwait"
  ];

  # fix electron on wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable bluetooth
  hardware.bluetooth.enable = true;

  # add udev rules for flashing qmk firmware
  services.udev.packages = [ pkgs.qmk-udev-rules ];

  system.stateVersion = "25.11";
}
