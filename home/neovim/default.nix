{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    nixpkgs.pkgs = pkgs;
    defaultEditor = true;
    opts = {
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus"; # Use system clipboard
      smartindent = true;

      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      softtabstop = 2;
    };

    globals.mapleader = " ";

    extraConfigLua = builtins.readFile ./theme.lua;

    plugins = {
      # highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              formatting.command = [ "nixfmt" ];
              nixpkgs.expr = "import <nixpkgs> { }";
            };
          };

          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };

        keymaps.lspBuf = {
          gd = "definition";
          gr = "references";
          K = "hover";
          "<leader>rn" = "rename";
        };
      };

      # auto-format
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 500;
          };
          formatters_by_ft = {
            nix = [ "nixfmt" ];
          };
        };
      };

      # ui
      telescope.enable = true;
      lualine.enable = true;
      web-devicons.enable = true;

      # autocomplete
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
        };
      };

      # git highlighting
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
        };
      };
    };

    extraPackages = with pkgs; [
      nixfmt
    ];
  };
}
