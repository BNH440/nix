{ ... }:

{
  imports = [
    ../../home/default.nix
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
  };

  nixpkgs.config.allowUnfree = true;
}
