{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  wallpaper = pkgs.fetchurl {
    url = "https://files.blakehaug.com/share/wallpapers/kafu.png";
    sha256 = "14bq4rna783jy0flmsm8g0ik64d100acr8j11rnq7s8nlnz5jbhs";
  };
in
{
  imports = [ ];

  # gnome
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    power-profiles-daemon
  ];
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            pkgs.gnomeExtensions.paperwm.extensionUuid
            pkgs.gnomeExtensions.kimpanel.extensionUuid
            pkgs.gnomeExtensions.blur-my-shell.extensionUuid
          ];
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          clock-format = "12h";
          clock-show-weekday = true;
          clock-show-seconds = true;
        };
        "org/gnome/desktop/calendar".show-weekdate = true; # add week numbers in calendar
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://" + wallpaper;
          picture-uri-dark = "file://" + wallpaper;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = 20.0;
          night-light-schedule-to = 6.0;
        };
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing"; # no suspend
        "org/gnome/desktop/session".idle-delay = lib.gvariant.mkUint32 1800; # screen off after 30mins
      };
    }
  ];

  # Graphical apps
  environment.systemPackages = with pkgs; [
    # gnome
    gnomeExtensions.paperwm
    gnomeExtensions.kimpanel
    gnomeExtensions.blur-my-shell

    # Misc
    kdePackages.konsole
    mpv
    zed-editor
    kdePackages.filelight
    kdePackages.partitionmanager
    gparted
    vesktop
    obsidian
    spotify
    google-chrome
    osu-lazer-bin
    signal-desktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    jellyfin-desktop
    transmission_4-qt6
    gimp
    davinci-resolve
    prusa-slicer
    bitwarden-desktop
    graphite
    cinny-desktop
    imagemagick
    sigil
    tor-browser
    sublime
    sublime-merge

    # Gaming
    lutris
    protonplus
    prismlauncher
    wineWow64Packages.stagingFull
    winetricks
    protontricks
  ];

  # Gaming
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.breeze # fix cursor theme
    ];
  };

  # Genshin (see https://github.com/ezKEa/aagl-gtk-on-nix)
  nix.settings = inputs.aagl.nixConfig;
  programs.anime-game-launcher.enable = true;

  # OBS
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Defaults
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols

      # Japanese
      ipaexfont

      # Terminal font
      meslo-lgs-nf
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "Fira Code"
          "IPAexGothic"
        ];
        sansSerif = [
          "Noto Sans"
          "IPAexGothic"
        ];
        serif = [
          "Noto Serif"
          "IPAexMincho"
        ];
      };
    };

    fontDir.enable = true;
  };
}
