{
  pkgs,
  ...
}:

{
  imports = [ ];

  # easyeffects defined in ./home.nix

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
