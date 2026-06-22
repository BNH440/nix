{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ];

  # KDE
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  services.xserver.enable = true;

  # Graphical apps
  environment.systemPackages = with pkgs; [
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
  ];

  # TODO remove once bitwarden-desktop has updated electron
  # https://github.com/NixOS/nixpkgs/issues/526914
  # https://github.com/bitwarden/clients/pull/20448
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
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
