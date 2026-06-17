{
  ...
}:

{
  systemd = {
    services = {
      "nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMScoreAdjust = 1000;
      };
    };
  };
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 0;
      max-jobs = "auto";
    };
  };
}
