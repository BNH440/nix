{
  config,
  lib,
  ...
}:

let
  backupTemplate = {
    passwordFile = config.age.secrets.ito-restic-backup-password.path;
    initialize = true;
    user = "blakeh";
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
    runCheck = true;
  };
in
{
  age.secrets.ito-restic-backup-password = {
    owner = "blakeh";
    group = "users";
    mode = "600";
    rekeyFile = ../../secrets/ito-restic-backup-password.age;
  };

  services.restic.backups = {
    ito-zfs-backup = lib.mkMerge [
      {
        paths = [ "/data" ];
        exclude = [
          "/data/games"
          "/data/backups"
        ];
        repository = "sftp:backup:/home/restic/ito-zfs-backup";
      }
      backupTemplate
    ];
    ito-home-backup = lib.mkMerge [
      {
        paths = [ "/home/blakeh" ];
        exclude = [
          "/home/blakeh/.local"
        ];
        repository = "sftp:backup:/home/restic/ito-home-backup";
      }
      backupTemplate
    ];
  };
}
