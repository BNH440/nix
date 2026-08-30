{
  ...
}:

{
  imports = [
    ./minecraft/default.nix
    ./files.nix
    ./git.nix
  ];

  blakehaug-web.enable = true;
}
