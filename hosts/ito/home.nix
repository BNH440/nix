{
  pkgs,
  ...
}:

{
  imports = [
    ../../home/default.nix
  ];

  # autostart
  home.file.".config/autostart/com.github.wwmm.easyeffects.desktop".text = ''
    [Desktop Entry]
    Name=Easy Effects
    Comment=Easy Effects Service
    Exec=${pkgs.easyeffects}/bin/easyeffects --hide-window --service-mode
    Icon=com.github.wwmm.easyeffects
    StartupNotify=false
    Terminal=false
    Type=Application
    X-GNOME-Autostart-Phase=Application
    X-KDE-autostart-phase=2
  '';
  home.file.".config/autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    Categories=System;Utility;
    Comment=Start Input Method
    Exec=${pkgs.qt6Packages.fcitx5-with-addons}/bin/fcitx5
    GenericName=Input Method
    Icon=fcitx
    Name=Fcitx 5
    StartupNotify=false
    Terminal=false
    Type=Application
    X-GNOME-AutoRestart=false
    X-GNOME-Autostart-Notify=false
    X-KDE-StartupNotify=false
    X-KDE-Wayland-Interfaces=org_kde_plasma_window_management
    X-KDE-Wayland-VirtualKeyboard=true
    X-KDE-autostart-after=panel
  '';
  home.file.".config/autostart/openrgb.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=${pkgs.openrgb}/bin/openrgb --profile profile
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name=OpenRGB Profile
    Comment=Autoloads OpenRGB profile on login
  '';

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
