{
  pkgs,
  ...
}:

{
  imports = [ ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = [
        {
          name = "Desktop";
          auto-detach = "true";
        }
        {
          name = "1080p Desktop";
          prep-cmd = [
            {
              do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.1920x1080@60";
              undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.3840x1600@160";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
  };
}
