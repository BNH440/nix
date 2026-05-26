{
  inputs,
  pkgs,
  ...
}:

let
  kafu = pkgs.fetchurl {
    url = "https://files.blakehaug.com/share/wallpapers/kafu.png";
    sha256 = "14bq4rna783jy0flmsm8g0ik64d100acr8j11rnq7s8nlnz5jbhs";
  };
  night = pkgs.fetchurl {
    url = "https://files.blakehaug.com/share/wallpapers/night.png";
    sha256 = "0rv9s187x5zvpl27vxv24pn2xw96lqh84p8dlb921v5va59fdbrs";
  };
in
{
  imports = [
    ./common.nix
  ];

  # Systemwide dark mode, including Firefox.
  # dconf.settings = {
  #   "org/gnome/desktop/interface" = {
  #     color-scheme = "prefer-dark";
  #   };
  # };

  # gtk.font.size = 32;

  programs = {
    firefox = {
      enable = true;
      # policies = {
      #   # got this from https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
      #   DisableTelemetry = true;
      #   DisableFirefoxStudies = true;
      #   EnableTrackingProtection = {
      #     Value = true;
      #     Locked = true;
      #     Cryptomining = true;
      #     Fingerprinting = true;
      #   };
      #   DisablePocket = true;
      # };
      profiles = {
        "blakeh" = {
          id = 0;
          isDefault = true;

          search.engines = {
            "Nix Packages" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            "Nix Options" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            "Home Manager Options" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@hm" ];
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
          };

          settings = {
            "browser.startup.homepage" =
              "https://printhost.ocf.berkeley.edu/jobs/|http://logjam/|http://papercut/|http://pagefault/|http://fishpaper";
          };

          extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            bitwarden
            darkreader
          ];

          extraConfig = ''
            user_pref("extensions.autoDisableScopes", 0);
            user_pref("extensions.enabledScopes", 15);
          '';
        };
      };
    };

    #   kitty = {
    #     enable = true;
    #     enableGitIntegration = true;

    #     # https://github.com/kovidgoyal/kitty-themes/tree/master/themes for more themes
    #     themeFile = "gruvbox-dark-hard";

    #     font = {
    #       name = "hack";
    #       #size = 20.0;
    #     };
    #   };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${kafu}"
      ];
      wallpaper = [
        ", ${kafu}"
      ];
    };
  };
}
