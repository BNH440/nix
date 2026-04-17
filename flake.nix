{
  description = "NixOS flake for blakeh nix machines";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-flake.url = "github:ArMonarch/Neovim-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database-unstable = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    git-hooks.url = "github:cachix/git-hooks.nix";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    attic.url = "github:zhaofengli/attic";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      agenix-rekey,
      home-manager,
      home-manager-unstable,
      neovim-flake,
      nix-index-database,
      nix-index-database-unstable,
      nix-darwin,
      flake-utils,
      colmena,
      disko,
      lanzaboote,
      nix-flatpak,
      aagl,
      zen-browser,
      attic,
      ...
    }@inputs:
    let
      pubkeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK6PlfQq5LYIOHTnPwQvJeiGo3MYDxBRb+KdTqrffxFnAAAABHNzaDo=" # main yubikey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPs3+fHihwZSBQVtoXffCtSSmBBDb/0NY+BPDIo+FKh9AAAABHNzaDo=" # backup yubikey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3SnQlFllOIBsQmgGB8owAyKviKNoRvleS/eIbK4/8B" # hikari
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVa9eWADJr7DQf0c7xiJGl2+6KYF9LeGJUfSJj2mT/S" # ito
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeZsmzMQHKkaAk/PFx1yJG6mijENIy9nFeHySQKJ3R6" # kako
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVCtRg036ANP+l/vmvzj6EJZL2Ic8s5y5tqyMoaOzrs" # ronri
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF16Vm3gwviIP1dg/EAx1xxofFm8No8zN6UGYpEM4D72KusDFYwa2M4F+bvf+a0K01OJNNGUnsxFTyizQxwsPj4=" # phone
      ];
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      nixosConfigurations = {
        ronri = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs pubkeys; };
          modules = [
            ./hosts/ronri/default.nix
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            attic.nixosModules.atticd
            nix-index-database.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blakeh = ./home/default.nix;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };
        ito = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs pubkeys; };
          modules = [
            ./hosts/ito/default.nix
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            nix-index-database-unstable.nixosModules.default
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            nix-flatpak.nixosModules.nix-flatpak
            home-manager-unstable.nixosModules.home-manager
            aagl.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blakeh = ./hosts/ito/home.nix;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };
      };
      darwinConfigurations.hikari = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/hikari/default.nix
          # agenix.darwinModules.default
          # agenix-rekey.darwinModules.default
          nix-index-database.darwinModules.default
          home-manager-unstable.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.blakeh = ./hosts/hikari/home.nix;
            home-manager.backupFileExtension = "hm-backup";
          }
        ];
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
          nodeSpecialArgs = builtins.mapAttrs (
            name: value: value._module.specialArgs
          ) self.nixosConfigurations;
        };

        ronri = {
          imports = self.nixosConfigurations.ronri._module.args.modules;
          deployment = {
            targetHost = "ronri";
            targetUser = "blakeh";
            buildOnTarget = true;
          };
        };

        ito = {
          imports = self.nixosConfigurations.ito._module.args.modules;
          deployment = {
            targetHost = "ito";
            targetUser = "blakeh";
            buildOnTarget = true;
          };
        };
      };

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
        # darwinConfigurations = self.darwinConfigurations or { };
      };

      formatter = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          config = self.checks.${system}.pre-commit-check.config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );

      checks = forEachSystem (system: {
        pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
          };
        };
      });
    }

    // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ agenix-rekey.overlays.default ];
      };
      devShells.default =
        let
          inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
        in
        pkgs.mkShell {
          inherit shellHook;
          buildInputs = enabledPackages;
          packages = [
            pkgs.agenix-rekey
            pkgs.age-plugin-fido2-hmac
            colmena.packages.${system}.colmena
          ];
        };
    });
}
