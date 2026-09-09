{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  cfg = config.niks3;
  rootDomain = config.web.rootDomain;
  publicURL = "nixcache.${rootDomain}";
  githubRepo = "BNH440/nix";
  niks3Pkgs = inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.niks3 = {
    enable = lib.mkEnableOption "niks3 on this host";
    db = lib.mkOption {
      type = lib.types.enum [
        "local-seaweedfs"
        "remote"
      ];
      default = "local-seaweedfs";
    };

    niks3-auth-token = lib.mkOption {
      type = lib.types.str;
    };
    niks3-signing-key = lib.mkOption {
      type = lib.types.str;
    };
    niks3-s3-access-key = lib.mkOption {
      type = lib.types.str;
    };
    niks3-s3-secret-key = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.niks3 = {
        enable = true;
        package = niks3Pkgs.niks3;
        serverPackage = niks3Pkgs.niks3-server;
        httpAddr = "127.0.0.1:5751";

        s3 = {
          bucket = "nixcache";
          accessKeyFile = cfg.niks3-s3-access-key;
          secretKeyFile = cfg.niks3-s3-secret-key;
        };

        apiTokenFile = cfg.niks3-auth-token;
        signKeyFiles = [ cfg.niks3-signing-key ];
        cacheUrl = "https://${publicURL}";

        oidc.providers.github = {
          issuer = "https://token.actions.githubusercontent.com";
          audience = "https://${publicURL}";
          boundClaims = {
            repository = [ githubRepo ];
          };
        };

        nginx = {
          enable = true;
          domain = publicURL;
          enableACME = false;
          forceSSL = true;
        };

        gc = {
          enable = true;
          olderThan = "2160h"; # 3 months
          failedUploadsOlderThan = "12h";
          schedule = "daily";
          randomizedDelaySec = 1800;
        };
      };

      systemd.services.niks3 = {
        after = [ "seaweedfs.service" ];
        requires = [ "seaweedfs.service" ];
      };

      services.nginx.virtualHosts.${publicURL} = {
        useACMEHost = rootDomain;
      };

      security.acme.certs."${rootDomain}".extraDomainNames = [ publicURL ];
    })

    (lib.mkIf (cfg.enable && (cfg.db == "local-seaweedfs")) (
      let
        dbPort = 8333;
      in
      {
        niks3-db = {
          enable = true;
          url = publicURL;
          port = dbPort;
          niks3-s3-access-key = cfg.niks3-s3-access-key;
          niks3-s3-secret-key = cfg.niks3-s3-secret-key;
        };

        services.niks3 = {
          readProxy.enable = true;
          s3 = {
            endpoint = "${publicURL}:${toString dbPort}";
            useSSL = false;
          };
        };
      }
    ))

    (lib.mkIf (cfg.enable && (cfg.db == "remote")) {
      services.niks3 = {
        readProxy.enable = true;
        s3 = {
          endpoint = "cache.kafu.observer";
          useSSL = true;
        };
      };
    })
  ];
}
