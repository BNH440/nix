{
  ...
}:

let
  passwordFile = "/run/agenix/macbook-restic-backup-password"; # secret defined in ./default.nix
  pcBackup = {
    inherit passwordFile;
    repository = "sftp:ito:/data/backups/macbook-userfiles-backup";
  };
  onedriveBackup = {
    inherit passwordFile;
    repository = "rclone:onedrive:macbook-userfiles-backup";
  };
in
{
  services.restic = {
    enable = true;
    backups = {
      pc = pcBackup;
      onedrive = onedriveBackup;
    };
  };
}
