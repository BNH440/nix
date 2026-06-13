{
  description = "NixOS aarch64 test VM for niri + Noctalia shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      niri,
      noctalia,
      ...
    }@inputs:
    let
      # Build for aarch64-linux (Apple Silicon runs aarch64 VMs natively)
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.niri-test = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          niri.nixosModules.niri
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };

      # nix build .#image   → QCOW2 disk image
      # nix build .#vm      → VM runner script
      # nix build            → defaults to image
      packages.${system} = {
        image = self.nixosConfigurations.niri-test.config.system.build.qcow2Image;
        vm = self.nixosConfigurations.niri-test.config.system.build.vm;
        default = self.packages.${system}.image;
      };
    };
}
