{
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./graphical.nix
    ./disks.nix
    ./nvidia.nix
    ./audio.nix
    ./boot.nix
    ./tablet.nix
    ./vm.nix
    ./backup.nix
    # ./remote-desktop.nix
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
  services.zfs.autoScrub.enable = true;

  # yubikey support
  services.pcscd.enable = true;

  # openrgb setup
  services.hardware.openrgb = {
    enable = true;
    startupProfile = "profile";
  };

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

  # enable i2c for monitor brightness control
  hardware.i2c.enable = true;

  # enable rasdaemon to monitor cpu crashes
  hardware.rasdaemon.enable = true;

  # add wake-in script
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "wake-in" ''
      sudo sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm"
      sudo sh -c "echo \`date '+%s' -d '+ $1'\` > /sys/class/rtc/rtc0/wakealarm"
      sudo systemctl suspend
    '')
  ];

  system.stateVersion = "25.11";
}
