{
  lib,
  pkgs,
  ...
}:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
    settings = {
      color_scheme = "kafDark";
      font = lib.generators.mkLuaInline ''wezterm.font("MesloLGS NF")'';
      hide_tab_bar_if_only_one_tab = false;
      window_decorations = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "INTEGRATED_BUTTONS|RESIZE";
      font_size = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 13)
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 11)
      ];
      window_background_opacity = 0.98;
    };
    colorSchemes = {
      kafDark = {
        ansi = [
          "#15142f"
          "#e36981"
          "#8fbf9f"
          "#e8c547"
          "#7b6fd9"
          "#e070b8"
          "#9aaee8"
          "#c4c3ca"
        ];
        brights = [
          "#646378"
          "#ff8095"
          "#a8d4b6"
          "#f5d76e"
          "#9d8fff"
          "#ff8fd0"
          "#bcc4ff"
          "#ffffff"
        ];
        background = "#15142f";
        cursor_bg = "#e19dce";
        cursor_border = "#e19dce";
        cursor_fg = "#15142f";
        foreground = "#f0ebff";
        selection_bg = "#e19dce";
        selection_fg = "#15142f";
      };
    };
  };
}
