{
  inputs,
  pkgs,
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

  nixpkgs.config.permittedInsecurePackages = [ ];

  # set nix version manually to avoid libgit2 issue
  nix.package = pkgs.unstable.nix;
}
