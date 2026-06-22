{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    # Essential Packages (All others are in home/default.nix)
    vim
    wget
    tree
    htop
    fastfetch
    git
    dig

    # Cache
    inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3

    nixos-firewall-tool
  ];

  programs.mosh.enable = true;

  programs.nix-index-database.comma.enable = true;

  programs.direnv.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/blakeh/.nixos";
  };

  nix.optimise = {
    automatic = true;
    dates = "weekly";
  };

  programs.tmux.enable = true;
  programs.screen.enable = true;

  environment.shellAliases = {
    switch = "cd ~/.nixos && git pull && nh os switch && cd -";
  };
}
