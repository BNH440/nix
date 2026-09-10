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
    publicURL = lib.mkOption {
      type = lib.types.str;
      default = "cache.${rootDomain}";
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

        oidc.providers.github = {
          issuer = "https://token.actions.githubusercontent.com";
          audience = "https://${cfg.publicURL}";
          boundClaims = {
            repository = [ githubRepo ];
          };
        };

        nginx = {
          enable = true;
          domain = cfg.publicURL;
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

      services.nginx.virtualHosts.${cfg.publicURL} = {
        useACMEHost = rootDomain;
      };

      security.acme.certs."${rootDomain}".extraDomainNames = [ cfg.publicURL ];
    })

    (lib.mkIf (cfg.enable && (cfg.db == "local-seaweedfs")) (
      let
        dbPort = 8333;
      in
      {
        niks3-db = {
          enable = true;
          url = cfg.publicURL;
          port = dbPort;
          niks3-s3-access-key = cfg.niks3-s3-access-key;
          niks3-s3-secret-key = cfg.niks3-s3-secret-key;
        };

        systemd.services.niks3 = {
          after = [ "seaweedfs.service" ];
          requires = [ "seaweedfs.service" ];
        };

        services.niks3 = {
          readProxy.enable = true;
          cacheUrl = "https://${cfg.publicURL}";
          s3 = {
            endpoint = "${cfg.publicURL}:${toString dbPort}";
            useSSL = false;
          };
        };
      }
    ))

    (lib.mkIf (cfg.enable && (cfg.db == "remote")) {
      services.niks3 = {
        readProxy.enable = false;
        cacheUrl = "https://cache.kafu.observer";
        serverUrl = "https://${cfg.publicURL}";
        s3 = {
          endpoint = "f5fa3320245d2a52b180ad0ccfc47e8f.r2.cloudflarestorage.com";
          useSSL = true;
          region = "auto";
        };
      };
    })
  ];
}
