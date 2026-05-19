{
  config,
  lib,
  ...
}:

let
  cfg = config.blakehaug-web;
in
{
  options.blakehaug-web = {
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

    serveRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Serve the root `blakehaug.com` static site (and the
        `www.blakehaug.com` → `blakehaug.com` redirect) from this host.
        Content lives at `/var/www/blakehaug.com` and is owned by the
        `deploy` user so GitHub Actions can rsync into it. Exactly one
        host should set this.
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
        Additional domains that should 302-redirect to blakehaug.com. These
        aren't on Cloudflare-managed DNS, so they're issued via HTTP-01
        (nginx forces `dnsProvider = null` on `enableACME` certs, which is
        the desired behavior here).
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
          globalRedirect = "blakehaug.com";
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
      };
    })

    (lib.mkIf (cfg.enable && cfg.serveRoot) {
      services.nginx.virtualHosts = {
        "blakehaug.com" = {
          useACMEHost = "blakehaug.com";
          forceSSL = true;
          root = "/var/www/blakehaug.com";
        };
        "www.blakehaug.com" = {
          useACMEHost = "blakehaug.com";
          forceSSL = true;
          globalRedirect = "blakehaug.com";
        };
      };

      # Declares the shared `blakehaug.com` cert (DNS-01 details come from
      # security.acme.defaults). Other modules on this host can piggyback
      # by appending to `extraDomainNames`.
      security.acme.certs."blakehaug.com".extraDomainNames = [
        "www.blakehaug.com"
      ];

      systemd.tmpfiles.rules = [
        "d /var/www/blakehaug.com 0755 deploy nginx -"
      ];

      users.users.deploy = {
        isNormalUser = true;
        createHome = true;
        home = "/home/deploy";
        description = "GitHub Actions Deployment User";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/BzaxAtrueXUriQLlEFaM6c4QF1OKH4teqFVhtOU54 github-actions-deploy"
        ];
      };
    })
  ];
}
