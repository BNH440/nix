{
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
      vol1 = {
        type = "disk";
        device = "/dev/disk/by-uuid/21a7a85d-0d46-4976-8a17-97fdec04fdc0";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/vol1";
          mountOptions = [
            "nofail"
            "x-systemd.device-timeout=30"
          ];
        };
      };
    };
  };
}
