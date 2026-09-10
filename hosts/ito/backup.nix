# Uses services.restic.backups (one job per repository).
# Each job gets its own systemd service/timer, logs, and CLI wrapper.
#
# CLI wrappers are added to PATH automatically:
#   restic-backups-minecraft-onedrive snapshots
#   restic-backups-minecraft-pc snapshots
#
# Manual trigger:
#   systemctl start restic-backups-minecraft-onedrive
#
# View logs:
#   journalctl -u restic-backups-minecraft-onedrive

{
  config,
  ...
}:

{
  age.secrets.ito-restic-backup-password = {
    owner = "blakeh";
    group = "users";
    mode = "600";
    rekeyFile = ../../secrets/ito-restic-backup-password.age;
  };

  services.restic.backups = {
    ito-zfs-backup = {
      paths = [ "/data" ];
      exclude = [
        "/data/games"
        "/data/backups"
      ];
      repository = "sftp:backup:/home/restic/ito-zfs-backup";
      passwordFile = config.age.secrets.ito-restic-backup-password.path;
      initialize = true;
      user = "blakeh";

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
        RandomizedDelaySec = "5min";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
      runCheck = true;
    };
  };
}
