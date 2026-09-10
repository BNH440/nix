{
  ...
}:

{
  imports = [
    ./minecraft/default.nix
    ./files.nix
    ./git.nix
    ./cache.nix
  ];

  web = {
    enable = true;
    rootDomain = "kafu.observer";
  };
}
