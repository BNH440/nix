{
  inputs,
  ...
}:

let
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
in
{
  nixpkgs.overlays = [ unstable-packages ];
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    # TODO remove once bitwarden-desktop has updated electron
    # https://github.com/NixOS/nixpkgs/issues/526914
    # https://github.com/bitwarden/clients/pull/20448
    "electron-39.8.10"
  ];
}
