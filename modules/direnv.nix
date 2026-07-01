{
  ...
}:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    settings.global.log_filter = "^$";
  };
}
