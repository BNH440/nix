{
  lib,
  ...
}:

{
  # restic backup secret
  age.secrets.macbook-restic-backup-password = {
    owner = "blakeh";
    group = "staff";
    rekeyFile = ../../../secrets/macbook-restic-backup-password.age;
  };

  launchd.user.agents =
    let
      # targets from ./home.nix
      backup-targets = [
        "pc"
        "onedrive"
      ];
      exclude = [
        "Photo Booth Library"
        "Photos Library.photoslibrary"
        "node_modules"
        "/Volumes/Crucial X9/.Trashes"
        "/Users/blakehaug/.config/darktable/data.db-pre-*"
        "/Users/blakehaug/.config/darktable/library.db-pre-*"
      ];
      documentsBackupPaths = [
        "/Users/blakehaug/Documents"
        "/Users/blakehaug/Pictures"
      ];
      configsBackupPaths = [
        "/Users/blakehaug/Library/Application Support/zen"
        "/Users/blakehaug/.ssh"
        "/Users/blakehaug/.zshrc"
        "/Users/blakehaug/scripts"
        "/Users/blakehaug/.config"
      ];
      externalSSDBackupPath = lib.escapeShellArg "/Volumes/Crucial X9";
      allPaths = documentsBackupPaths ++ configsBackupPaths;
      pathsSep = lib.escapeShellArgs allPaths;
      excludeList = builtins.concatStringsSep " " (map (x: "--exclude ${lib.escapeShellArg x}") exclude);
      host = "blakes-macbook-pro";
      EnvironmentVariables.PATH = "/etc/profiles/per-user/blakeh/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin";
    in
    builtins.listToAttrs (
      map (target: {
        name = "restic-${target}-backup-auto";
        value = {
          script = "restic-${target} backup ${pathsSep} ${excludeList} --host ${host}";
          serviceConfig = {
            inherit EnvironmentVariables;
            # automatic activation
            StartCalendarInterval = {
              Hour = 1;
              Minute = 30;
            }; # 1:30 AM
            StandardOutPath = "/Users/blakeh/Library/Logs/restic-${target}-backup-auto.out";
            StandardErrorPath = "/Users/blakeh/Library/Logs/restic-${target}-backup-auto.err";
          };
        };
      }) backup-targets
    )
    // builtins.listToAttrs (
      map (target: {
        name = "restic-${target}-backup-external-ssd-manual";
        value = {
          script = "restic-${target} backup ${externalSSDBackupPath} ${excludeList} --host ${host}";
          serviceConfig = {
            inherit EnvironmentVariables;
            # manual activation
            StandardOutPath = "/Users/blakeh/Library/Logs/restic-${target}-backup-external-ssd-manual.out";
            StandardErrorPath = "/Users/blakeh/Library/Logs/restic-${target}-backup-external-ssd-manual.err";
          };
        };
      }) backup-targets
    )
    // builtins.listToAttrs (
      map (target: {
        name = "restic-${target}-prune-auto";
        value = {
          script = ''
            set -e
            restic-${target} forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --prune
            restic-${target} check
          '';
          serviceConfig = {
            inherit EnvironmentVariables;
            # automatic activation
            StartCalendarInterval = {
              Day = 1;
              Hour = 3;
              Minute = 30;
            }; # 3:30 AM on the 1st of each month
            StandardOutPath = "/Users/blakeh/Library/Logs/restic-${target}-prune-auto.out";
            StandardErrorPath = "/Users/blakeh/Library/Logs/restic-${target}-prune-auto.err";
          };
        };
      }) backup-targets
    );

  # log rotation
  environment.etc."newsyslog.d/restic.conf".text = ''
    # logfilename                              [owner:group]   mode count size when  flags
    /Users/blakeh/Library/Logs/restic-*.out    blakeh:staff    644  5     5000 * JG
    /Users/blakeh/Library/Logs/restic-*.err    blakeh:staff    644  5     5000 * JG
  '';
}
