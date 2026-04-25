# enable opentabletdriver for drawing tablet
{
  ...
}:

{
  imports = [ ];

  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];
  boot.blacklistedKernelModules = [
    "wacom"
    "hid_uclogic"
  ];
  systemd.user.services.opentabletdriver = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2s";
    };
    after = [ "plasma-core.target" ];
    wants = [ "plasma-core.target" ];
  };
}
