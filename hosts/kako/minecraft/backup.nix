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
  pkgs,
  config,
  ...
}:

let
  # Shared settings across all minecraft backup jobs
  backupPaths = [ "/mnt/vol1/minecraft-servers/data" ];
  backupExclude = [
    "logs"
    "libraries"
    "versions"
    "cache"
    "*.db"
    "*.db-shm"
    "*.db-wal"
  ];
  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 5"
    "--keep-monthly 12"
  ];

  # Pause server writes before backup, resume after (even on failure)
  backupPrepareCommand = ''
    ${pkgs.podman}/bin/podman exec soulcraft rcon-cli save-off || true
    ${pkgs.podman}/bin/podman exec soulcraft rcon-cli save-all || true
    sleep 5
  '';
  backupCleanupCommand = ''
    ${pkgs.podman}/bin/podman exec soulcraft rcon-cli save-on || true
  '';
in
{
  environment.systemPackages = with pkgs; [
    restic
    rclone
  ];

  age.secrets.minecraft-restic-backup-password.rekeyFile = ../../../secrets/minecraft-restic-backup-password.age;

  services.restic.backups = {
    minecraft-onedrive = {
      paths = backupPaths;
      exclude = backupExclude;
      repository = "rclone:onedrive:vm-minecraft-backup";
      passwordFile = config.age.secrets.minecraft-restic-backup-password.path;
      initialize = true;

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
        RandomizedDelaySec = "5min";
      };

      inherit pruneOpts;
      runCheck = true;

      inherit backupPrepareCommand backupCleanupCommand;
    };

    minecraft-pc = {
      paths = backupPaths;
      exclude = backupExclude;
      repository = "sftp:blakeh@ito:/data/backups/minecraft-vm-backup";
      passwordFile = config.age.secrets.minecraft-restic-backup-password.path;
      initialize = true;

      timerConfig = {
        OnCalendar = "*-*-* 04:15:00";
        Persistent = true;
        RandomizedDelaySec = "5min";
      };

      inherit pruneOpts;
      runCheck = true;

      inherit backupPrepareCommand backupCleanupCommand;
    };
  };
}
