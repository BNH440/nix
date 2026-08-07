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

  paperwm-patched = (
    pkgs.gnomeExtensions.paperwm.overrideAttrs (prevAttrs: {
      patches = (prevAttrs.patches or [ ]) ++ [
        ./paperwm-scroll-windows.patch
      ];
    })
  );
in
{
  imports = [ ];

  # gnome
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  systemd.services.power-profiles-daemon.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    power-profiles-daemon
  ];
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      mozc
    ];
  };
  # environment.sessionVariables.GTK_THEME = "Adwaita:dark";
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            paperwm-patched.extensionUuid
            blur-my-shell.extensionUuid
            brightness-control-using-ddcutil.extensionUuid
          ];
          favorite-apps = [
            "zen.desktop"
            "dev.zed.Zed.desktop"
            "org.gnome.Nautilus.desktop"
            "org.wezfurlong.wezterm.desktop"
          ];
        };
        "org/gnome/desktop/interface" = {
          # color-scheme = "prefer-dark"; # added to ./home.nix instead
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
        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.gvariant.mkTuple [
              "xkb"
              "us"
            ])
            (lib.gvariant.mkTuple [
              "ibus"
              "mozc-jp"
            ])
          ];
        };
        "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
        "org/gnome/shell/extensions/paperwm" = {
          show-workspace-indicator = false; # show workspace pill indicator
          selection-border-radius-top = lib.gvariant.mkInt32 12;
          selection-border-radius-bottom = lib.gvariant.mkInt32 12;
        };
        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          show-delete-permanently = true;
          sort-directories-first = false;
        };
        "org/gnome/desktop/search-providers".disabled = [ "org.gnome.Epiphany.desktop" ];
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = lib.gvariant.mkDouble 0.25;
        };
        "org/gnome/desktop/wm/keybindings" = {
          close = [
            "<Super>q"
            "<Alt>F4"
          ];
        };
        "org/gnome/shell/extensions/display-brightness-ddcutil" = {
          show-display-name = false;
          allow-zero-brightness = true;
          hide-system-indicator = true;
          button-location = lib.gvariant.mkInt32 1;
          increase-brightness-shortcut = [ "XF86MonBrightnessUp" ];
          decrease-brightness-shortcut = [ "XF86MonBrightnessDown" ];
        };
      };
    }
  ];

  # Graphical apps
  environment.systemPackages = with pkgs; [
    # gnome
    paperwm-patched
    gnomeExtensions.blur-my-shell
    gnomeExtensions.brightness-control-using-ddcutil
    ddcutil

    # qt theming
    qadwaitadecorations
    qadwaitadecorations-qt6
    qgnomeplatform
    qgnomeplatform-qt6

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
    transmission_4-gtk
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
