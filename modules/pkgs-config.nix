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

  nixpkgs.config.permittedInsecurePackages = [
    # TODO remove once bitwarden-desktop has updated electron
    # https://github.com/NixOS/nixpkgs/issues/526914
    # https://github.com/bitwarden/clients/pull/20448
    "electron-39.8.10"
  ];

  # set nix version manually to avoid libgit2 issue
  nix.package = pkgs.unstable.nix;

  # Binary cache
  nix.settings.substituters = [
    "https://nixcache.blakehaug.com"
    "https://nix-community.cachix.org" # nixvim
    "https://cache.nixos-cuda.org" # nvidia
    "https://ezkea.cachix.org" # aagl
  ];
  nix.settings.trusted-public-keys = [
    "nixcache.blakehaug.com-1:gCvj6d/XaSiX6YpelqVPX/kCZAfvAraN8BhtN22TG50="
    "nixcache.blakehaug.com:HA3O9E/cMwqguJQmIW49lnCTd7f8K6FnQC2aU0cPIxc="
    "main:gMJfiUKchtX1jmnXVUA3t54OMNLfCsTrj2nytssdU7A="

    "cache.ocf.berkeley.edu-1:6n9lihkjExzagz8GYR1QY/ZthT/XAKOy+ju5Jxd6wBg="

    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="

    "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
  ];
}
