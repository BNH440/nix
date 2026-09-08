{
  config,
  lib,
  ...
}:

let
  cfg = config.web;
in
{
  options.web = {
    enable = lib.mkEnableOption ''
      shared nginx + ACME setup for blakehaug.com sites. Provides a
      configured nginx (with a 404 default vhost), accepted ACME terms, and
      `security.acme.defaults` wired for Cloudflare DNS-01 — so any cert
      declared on this host via `security.acme.certs.<name>` (and referenced
      from a vhost via `useACMEHost`) inherits DNS-01 with no further
      boilerplate. The root `blakehaug.com` static site is opted into
      separately via `serveRoot`.
    '';

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "blake@blakehaug.com";
      description = "Contact email used for ACME registration.";
    };

    rootDomain = lib.mkOption {
      type = lib.types.str;
      default = "blakehaug.com";
    };

    serveRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        serve the root site with www redirect and content at `/var/www/{rootDomain}`
      '';
    };

    serveRootUser = lib.mkOption {
      type = lib.types.str;
      default = "blakehaug-web-deploy";
      description = ''
        user to give deploy access to the /var/www/{rootDomain} dir
      '';
    };

    serveRootKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/BzaxAtrueXUriQLlEFaM6c4QF1OKH4teqFVhtOU54 github-actions-deploy";
      description = ''
        ssh key for the github actions deployment user
      '';
    };

    redirectDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "blake.ocf.berkeley.edu"
        "ronri.ocf.berkeley.edu"
      ];
      description = ''
        add 302 redirects to the root domain
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;

        virtualHosts = {
          "default" = {
            default = true;
            locations."/" = {
              return = "404";
            };
          };
        }
        // lib.genAttrs cfg.redirectDomains (_: {
          enableACME = true;
          forceSSL = true;
          globalRedirect = cfg.rootDomain;
          redirectCode = 302;
        });
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      age.secrets.cloudflare-api-key.rekeyFile = ../secrets/cloudflare-api-key.age;

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = cfg.acmeEmail;
          dnsProvider = "cloudflare";
          environmentFile = config.age.secrets.cloudflare-api-key.path;
        };
        certs."${cfg.rootDomain}".group = "nginx";
      };
    })

    (lib.mkIf (cfg.enable && cfg.serveRoot) {
      services.nginx.virtualHosts = {
        "${cfg.rootDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/${cfg.rootDomain}";
        };
        "www.${cfg.rootDomain}" = {
          useACMEHost = cfg.rootDomain;
          forceSSL = true;
          globalRedirect = cfg.rootDomain;
        };
      };

      security.acme.certs."${cfg.rootDomain}".extraDomainNames = [
        "www.${cfg.rootDomain}"
      ];

      systemd.tmpfiles.rules = [
        "d /var/www/${cfg.rootDomain} 0755 ${cfg.serveRootUser} nginx -"
      ];

      users.groups."${cfg.serveRootUser}" = { };
      users.users."${cfg.serveRootUser}" = {
        isSystemUser = true;
        useDefaultShell = true;
        group = cfg.serveRootUser;
        description = "GitHub Actions Deployment User";
        openssh.authorizedKeys.keys = [
          cfg.serveRootKey
        ];
      };
    })
  ];
}
