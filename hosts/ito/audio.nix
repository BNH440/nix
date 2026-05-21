{
  pkgs,
  ...
}:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
