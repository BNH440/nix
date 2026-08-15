{
  pkgs,
  ...
}:

{
  imports = [
    ../../home/default.nix
    ../../home/gui.nix
  ];

  # gnome theme
  gtk = {
    enable = true;
    colorScheme = "dark";
  };

  # easyeffects
  home.packages = [ pkgs.easyeffects ];
  services.easyeffects = {
    enable = true;
    preset = "wh1000xm5";
    extraPresets = {
      wh1000xm5 = {
        output = {
          blocklist = [ ];
          "equalizer#0" = {
            balance = 0;
            bypass = false;
            input-gain = -5.79;
            left = {
              band0 = {
                frequency = 105;
                gain = -3.7;
                mode = "APO (DR)";
                mute = false;
                q = 0.7;
                slope = "x1";
                solo = false;
                type = "Lo-shelf";
                width = 4;
              };
              band1 = {
                frequency = 57.4;
                gain = 0.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.31;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band2 = {
                frequency = 117.9;
                gain = -1.2;
                mode = "APO (DR)";
                mute = false;
                q = 2.06;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band3 = {
                frequency = 184.1;
                gain = -5.2;
                mode = "APO (DR)";
                mute = false;
                q = 1.02;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band4 = {
                frequency = 574.2;
                gain = 1.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.84;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band5 = {
                frequency = 1217.3;
                gain = 3.3;
                mode = "APO (DR)";
                mute = false;
                q = 2.33;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band6 = {
                frequency = 2413;
                gain = 6.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.61;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band7 = {
                frequency = 3148;
                gain = -5.3;
                mode = "APO (DR)";
                mute = false;
                q = 2.76;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band8 = {
                frequency = 6076.3;
                gain = -2.6;
                mode = "APO (DR)";
                mute = false;
                q = 5.22;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band9 = {
                frequency = 10000;
                gain = 4.9;
                mode = "APO (DR)";
                mute = false;
                q = 0.7;
                slope = "x1";
                solo = false;
                type = "Hi-shelf";
                width = 4;
              };
            };
            mode = "IIR";
            num-bands = 10;
            output-gain = 0;
            pitch-left = 0;
            pitch-right = 0;
            right = {
              band0 = {
                frequency = 105;
                gain = -3.7;
                mode = "APO (DR)";
                mute = false;
                q = 0.7;
                slope = "x1";
                solo = false;
                type = "Lo-shelf";
                width = 4;
              };
              band1 = {
                frequency = 57.4;
                gain = 0.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.31;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band2 = {
                frequency = 117.9;
                gain = -1.2;
                mode = "APO (DR)";
                mute = false;
                q = 2.06;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band3 = {
                frequency = 184.1;
                gain = -5.2;
                mode = "APO (DR)";
                mute = false;
                q = 1.02;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band4 = {
                frequency = 574.2;
                gain = 1.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.84;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band5 = {
                frequency = 1217.3;
                gain = 3.3;
                mode = "APO (DR)";
                mute = false;
                q = 2.33;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band6 = {
                frequency = 2413;
                gain = 6.9;
                mode = "APO (DR)";
                mute = false;
                q = 1.61;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band7 = {
                frequency = 3148;
                gain = -5.3;
                mode = "APO (DR)";
                mute = false;
                q = 2.76;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band8 = {
                frequency = 6076.3;
                gain = -2.6;
                mode = "APO (DR)";
                mute = false;
                q = 5.22;
                slope = "x1";
                solo = false;
                type = "Bell";
                width = 4;
              };
              band9 = {
                frequency = 10000;
                gain = 4.9;
                mode = "APO (DR)";
                mute = false;
                q = 0.7;
                slope = "x1";
                solo = false;
                type = "Hi-shelf";
                width = 4;
              };
            };
            split-channels = false;
          };
          plugins_order = [ "equalizer#0" ];
        };
      };
    };
  };

  # wallpaper engine
  # services.linux-wallpaperengine = {
  #   enable = true;
  #   wallpapers = [
  #     {
  #       wallpaperId = "2530108698";
  #       monitor = "DP-3";
  #     }
  #   ];
  # };
}
