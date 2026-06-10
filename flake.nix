{
  description = "NixOS flake for blakeh nix machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake.url = "github:ArMonarch/Neovim-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tsexit = {
      url = "github:bnh440/tsexit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ocf-nix.url = "github:ocf/nix";
    ocf-home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "ocf-nix/nixpkgs";
    };
    ocf-firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "ocf-nix/nixpkgs";
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      agenix,
      agenix-rekey,
      home-manager,
      nix-index-database,
      nix-darwin,
      colmena,
      disko,
      lanzaboote,
      aagl,
      niks3,
      copyparty,
      ocf-nix,
      ocf-home-manager,
      ...
    }@inputs:
    let
      yubikeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK6PlfQq5LYIOHTnPwQvJeiGo3MYDxBRb+KdTqrffxFnAAAABHNzaDo=" # main yubikey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPs3+fHihwZSBQVtoXffCtSSmBBDb/0NY+BPDIo+FKh9AAAABHNzaDo=" # backup yubikey
      ];
      other-keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3SnQlFllOIBsQmgGB8owAyKviKNoRvleS/eIbK4/8B" # hikari
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVa9eWADJr7DQf0c7xiJGl2+6KYF9LeGJUfSJj2mT/S" # ito
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrnUA0gmnKiTLT079DSKTzCxUBV6bIkAIQhggzuOPo1" # kako
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVCtRg036ANP+l/vmvzj6EJZL2Ic8s5y5tqyMoaOzrs" # ronri
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF16Vm3gwviIP1dg/EAx1xxofFm8No8zN6UGYpEM4D72KusDFYwa2M4F+bvf+a0K01OJNNGUnsxFTyizQxwsPj4=" # phone
      ];
      pubkeys = yubikeys ++ other-keys;

      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      ocfPkgs = import ocf-nix.inputs.nixpkgs {
        system = "x86_64-linux";
      };

      hmOptions = hmConfig: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.blakeh = hmConfig;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
      };

      mkConfiguration =
        {
          hostname,
          hmConfig ? ./home/default.nix,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              pubkeys
              yubikeys
              self
              ;
          };
          modules = [
            ./hosts/${hostname}/default.nix
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            niks3.nixosModules.niks3
            niks3.nixosModules.niks3-auto-upload
            disko.nixosModules.disko
            nix-index-database.nixosModules.default
            home-manager.nixosModules.home-manager
            (hmOptions hmConfig)
          ]
          ++ extraModules;
        };

      nixosHosts = {
        ronri = { };
        kako = {
          extraModules = [
            copyparty.nixosModules.default
          ];
        };
        ito = {
          hmConfig = ./hosts/ito/home.nix;
          extraModules = [
            lanzaboote.nixosModules.lanzaboote
            aagl.nixosModules.default
          ];
        };
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        name: configArgs: mkConfiguration ({ hostname = name; } // configArgs)
      ) nixosHosts;

      darwinConfigurations.hikari = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/hikari/default.nix
          agenix.darwinModules.default
          agenix-rekey.darwinModules.default
          nix-index-database.darwinModules.default
          home-manager.darwinModules.home-manager
          (hmOptions ./hosts/hikari/home.nix)
        ];
      };

      homeConfigurations."ocf-server" = ocf-home-manager.lib.homeManagerConfiguration {
        pkgs = ocfPkgs;
        modules = [
          ./home/default.nix
          ./hosts/ocf/server.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      homeConfigurations."ocf-desktop" = ocf-home-manager.lib.homeManagerConfiguration {
        pkgs = ocfPkgs;
        modules = [
          ./home/config.nix
          ./hosts/ocf/desktop.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs { system = "x86_64-linux"; };
            nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
            nodeSpecialArgs = builtins.mapAttrs (
              name: value: value._module.specialArgs
            ) self.nixosConfigurations;
          };
        }
        // builtins.mapAttrs (name: config: {
          imports = config._module.args.modules;
          deployment = {
            targetHost = name;
            targetUser = "deploy-user";
            buildOnTarget = true;
          };
        }) self.nixosConfigurations
      );

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
        darwinConfigurations = self.darwinConfigurations;
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
      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend agenix-rekey.overlays.default;
          pre-commit-check-shell = inputs.git-hooks.lib.${system}.run {
            src = pkgs.runCommand "empty-dir" { } "mkdir $out";
            hooks = {
              nixfmt.enable = true;
            };
          };
          inherit (pre-commit-check-shell) shellHook enabledPackages;
        in
        {
          default = pkgs.mkShell {
            inherit shellHook;
            buildInputs = enabledPackages;
            packages = [
              pkgs.agenix-rekey
              pkgs.age-plugin-fido2-hmac
              colmena.packages.${system}.colmena
            ];
          };
        }
      );
    };
}
