{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    # Tools
    vim
    wget
    tree
    htop
    fastfetch
    git
    dig
    grep

    # Dev
    nil
    nixd

    # Cache
    inputs.niks3.packages.${pkgs.system}.niks3

    inputs.neovim-flake.packages.${pkgs.system}.default
  ];

  nixpkgs.config.allowUnfree = true;

  programs.mosh.enable = true;

  programs.nix-index-database.comma.enable = true;

  programs.direnv.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/blakeh/.nixos";
  };

  programs.tmux.enable = true;

  environment.shellAliases = {
    switch = "cd ~/.nixos && git pull && nh os switch && cd -";
  };

  environment.variables.VISUAL = "nvim";
}
