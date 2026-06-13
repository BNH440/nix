# Home Manager config for the test user
# Sets up niri keybindings and Noctalia shell integration
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "test";
  home.homeDirectory = "/home/test";

  # ── Noctalia shell ──────────────────────────────────────────────────
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };

  # ── Niri configuration ─────────────────────────────────────────────
  # The niri-flake homeModules.config is auto-imported when using
  # home-manager as a NixOS module alongside nixosModules.niri
  programs.niri.settings = {
    # Spawn Noctalia shell + foot terminal on startup
    spawn-at-startup = [
      { command = [ "noctalia" ]; }
    ];

    # Input settings
    input = {
      keyboard.xkb.layout = "us";
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
    };

    # Keybindings
    binds = {
      # Application launchers
      "Mod+T".action.spawn = [ "foot" ];
      "Mod+D".action.spawn = [ "fuzzel" ];

      # Window management
      "Mod+Q".action.close-window = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];

      # Focus navigation
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Up".action.focus-window-or-workspace-up = [ ];
      "Mod+Down".action.focus-window-or-workspace-down = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+K".action.focus-window-or-workspace-up = [ ];
      "Mod+J".action.focus-window-or-workspace-down = [ ];

      # Move windows
      "Mod+Shift+Left".action.move-column-left = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];
      "Mod+Shift+Up".action.move-window-up-or-to-workspace-up = [ ];
      "Mod+Shift+Down".action.move-window-down-or-to-workspace-down = [ ];
      "Mod+Shift+H".action.move-column-left = [ ];
      "Mod+Shift+L".action.move-column-right = [ ];
      "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [ ];
      "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [ ];

      # Workspace switching
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;

      # Move window to workspace
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;

      # Screenshots
      "Print".action.screenshot = [ ];
      "Mod+Print".action.screenshot-window = [ ];

      # Session
      "Mod+Shift+E".action.quit = [ ];
    };

    # Outputs / Resolution
    outputs."Virtual-1" = {
      mode = {
        width = 3024;
        height = 1800;
      };
      scale = 2.0;
    };

    # Layout
    layout = {
      gaps = 8;
      border = {
        enable = true;
        width = 2;
      };
      # Default column width
      default-column-width.proportion = 0.5;
    };

    # Visual tweaks
    prefer-no-csd = true;

    # Screenshot path
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  };

  # ── Foot terminal config ────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Fira Code:size=11";
        dpi-aware = "no";
      };
      colors = {
        # Catppuccin Mocha
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
      };
    };
  };

  # ── Fuzzel launcher ────────────────────────────────────────────────
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Inter:size=12";
        terminal = "foot";
        layer = "overlay";
      };
      colors = {
        # Catppuccin Mocha theme
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        border = "89b4faff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  home.stateVersion = "26.05";
}
