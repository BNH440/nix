{
  config,
  lib,
  ...
}:

let
  publicURL = "files.blakehaug.com";
in
{
  age.secrets.blakeh-copyparty-password = {
    owner = "copyparty";
    group = "copyparty";
    mode = "600";
    rekeyFile = ../../../secrets/blakeh-copyparty-password.age;
  };

  services.copyparty = {
    enable = true;

    settings = {
      i = "127.0.0.1"; # bind address
      p = 3923; # listen port (use a list for multiple: [ 3923 3924 ])
      e2dsa = true; # file indexing + filesystem scanning
      e2ts = true; # multimedia tag indexing
      ah-alg = "argon2"; # hash passwords with argon2
      shr = "/shr"; # enable share-link feature, mounted at /shr
      shr-adm = "blakeh"; # blakeh can manage all shares
      rproxy = 1; # trust X-Forwarded-For from the reverse proxy
    };

    # [accounts] section
    accounts = {
      blakeh = {
        passwordFile = config.age.secrets.blakeh-copyparty-password.path;
      };
    };

    # Volumes — each attribute name is the URL path.
    volumes = {
      # /drop: anonymous write-only inbox
      "/drop" = {
        path = "/srv/copyparty/drop";
        access = {
          A = "blakeh"; # full admin
          w = "*"; # anyone: write-only (upload, no listing, no reading)
        };
        flags = {
          fk = 8; # 8-char per-file key in returned URL
          nosub = true; # anon users can't create subfolders
          nohtml = true; # serve uploaded .html as plaintext
          dthumb = true; # no thumbnail generation on anonymous uploads
        };
      };

      # /share: blakeh full access, others can fetch by direct URL but can't list
      "/share" = {
        path = "/srv/copyparty/share";
        access = {
          A = "blakeh";
          g = "*"; # GET-by-URL only, no directory listing
        };
      };

      # /private: blakeh only — but share-links still work for individual files
      "/private" = {
        path = "/srv/copyparty/private";
        access = {
          A = "blakeh";
        };
      };
    };
  };

  # Make sure the data directories exist with the right owner.
  systemd.tmpfiles.rules = [
    "d /srv/copyparty            0755 copyparty copyparty - -"
    "d /srv/copyparty/drop       0755 copyparty copyparty - -"
    "d /srv/copyparty/share      0755 copyparty copyparty - -"
    "d /srv/copyparty/private    0700 copyparty copyparty - -"
  ];

  # NGINX config
  services.nginx = {
    clientMaxBodySize = lib.mkForce "0";
    appendHttpConfig = ''
      client_header_timeout 610m;
      client_body_timeout   610m;
      send_timeout          610m;
    '';
    upstreams.copyparty = {
      servers."127.0.0.1:3923" = { };
      extraConfig = ''
        keepalive 1;
      '';
    };
    virtualHosts."${publicURL}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3923";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_request_buffering off;
          proxy_buffering off;

          # Download speed tuning (600 → 1500 MiB/s per the upstream example)
          proxy_buffers 32 8k;
          proxy_buffer_size 16k;
          proxy_busy_buffers_size 24k;

          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };
  };
}
