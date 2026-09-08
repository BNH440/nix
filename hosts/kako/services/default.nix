{
  ...
}:

{
  imports = [
    ./minecraft/default.nix
    ./files.nix
    ./git.nix
  ];

  web.enable = true;
}
