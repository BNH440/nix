{
  ...
}:

{
  imports = [
    ./minecraft/default.nix
    ./git.nix
    ./cache.nix
  ];

  web = {
    enable = true;
    rootDomain = "kafu.observer";
  };
}
