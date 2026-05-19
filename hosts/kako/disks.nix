{
  pkgs,
  ...
}:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:6ecb7d63723";
  };

  systemd.services.iscsi-vol1 = {
    description = "iSCSI mount for vol1";
    after = [
      "network-online.target"
      "iscsid.service"
    ];
    wants = [
      "network-online.target"
      "iscsid.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      target="iqn.2015-12.com.oracleiaas:90da6b73-9ad6-498c-a5a5-31c5d8a24e85"
      portal="169.254.2.3:3260"

      if ! ${pkgs.openiscsi}/bin/iscsiadm -m node -T "$target" -p "$portal" >/dev/null 2>&1; then
        ${pkgs.openiscsi}/bin/iscsiadm -m node -o new -T "$target" -p "$portal"
      fi

      ${pkgs.openiscsi}/bin/iscsiadm -m node -o update -T "$target" -n node.startup -v automatic

      if ! ${pkgs.openiscsi}/bin/iscsiadm -m session -T "$target" -p "$portal" >/dev/null 2>&1; then
        ${pkgs.openiscsi}/bin/iscsiadm -m node -T "$target" -p "$portal" -l
      fi
    '';
  };

  systemd.tmpfiles.rules = [
    "d /mnt/vol1 0755 root root -"
  ];

  fileSystems."/mnt/vol1" = {
    device = "/dev/disk/by-uuid/21a7a85d-0d46-4976-8a17-97fdec04fdc0";
    fsType = "ext4";
    options = [
      "_netdev"
      "nofail"
      "x-systemd.requires=iscsi-vol1.service"
      "x-systemd.after=iscsi-vol1.service"
      "x-systemd.device-timeout=30"
    ];
  };
}
