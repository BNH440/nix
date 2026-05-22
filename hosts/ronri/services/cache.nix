{
  config,
  pkgs,
  inputs,
  ...
}:

let
  cacheURL = "nixcache.blakehaug.com";
  niks3URL = "niks3.blakehaug.com";
  githubRepo = "BNH440/nix";
  niks3Pkgs = inputs.niks3.packages.${pkgs.system};
in
{
  imports = [ ];

  age.secrets.niks3-auth-token.owner = "niks3";
  age.secrets.niks3-auth-token.group = "niks3";
  age.secrets.niks3-auth-token.mode = "0400";

  age.secrets.niks3-signing-key = {
    rekeyFile = ../../../secrets/niks3-signing-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-access-key = {
    rekeyFile = ../../../secrets/niks3-s3-access-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-secret-key = {
    rekeyFile = ../../../secrets/niks3-s3-secret-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };

  systemd.services.seaweedfs = {
    description = "SeaweedFS server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      StateDirectory = "seaweedfs";
      DynamicUser = true;
      Restart = "on-failure";
      LoadCredential = [
        "s3-access-key:${config.age.secrets.niks3-s3-access-key.path}"
        "s3-secret-key:${config.age.secrets.niks3-s3-secret-key.path}"
      ];
    };
    script = ''
      ACCESS_KEY=$(cat "$CREDENTIALS_DIRECTORY/s3-access-key")
      SECRET_KEY=$(cat "$CREDENTIALS_DIRECTORY/s3-secret-key")

      cat > /var/lib/seaweedfs/s3.json <<EOF
      {
        "defaultEffect": "Deny",
        "identities": [
          {
            "name": "niks3",
            "credentials": [{"accessKey": "$ACCESS_KEY", "secretKey": "$SECRET_KEY"}],
            "actions": ["Admin", "Read", "Write", "List", "Tagging"]
          },
          {
            "name": "anonymous",
            "actions": ["Read", "List"]
          }
        ]
      }
      EOF

      exec ${pkgs.seaweedfs}/bin/weed server \
        -dir=/var/lib/seaweedfs \
        -s3 -filer \
        -ip=nixcache.blakehaug.com \
        -ip.bind=:: \
        -s3.port=8333 \
        -volume.max=300 \
        -s3.config=/var/lib/seaweedfs/s3.json
    '';
  };

  services.niks3 = {
    enable = true;
    package = niks3Pkgs.niks3;
    serverPackage = niks3Pkgs.niks3-server;
    httpAddr = "127.0.0.1:5751";

    s3 = {
      endpoint = "nixcache.blakehaug.com:8333";
      bucket = "nixcache";
      useSSL = false;
      accessKeyFile = config.age.secrets.niks3-s3-access-key.path;
      secretKeyFile = config.age.secrets.niks3-s3-secret-key.path;
    };

    apiTokenFile = config.age.secrets.niks3-auth-token.path;
    signKeyFiles = [ config.age.secrets.niks3-signing-key.path ];

    # public substituter url
    cacheUrl = "https://${cacheURL}";

    oidc.providers.github = {
      issuer = "https://token.actions.githubusercontent.com";
      audience = "https://${niks3URL}";
      boundClaims = {
        repository = [ githubRepo ];
      };
    };

    # reading straight from seaweedfs for best performance
    readProxy.enable = false;

    # niks3 control server (uploads, auth, gc)
    nginx = {
      enable = true;
      domain = niks3URL;
      enableACME = false;
      forceSSL = true;
    };

    gc = {
      enable = true;
      olderThan = "4320h"; # 6 months
      failedUploadsOlderThan = "12h";
      schedule = "daily";
      randomizedDelaySec = 1800;
    };
  };

  systemd.services.niks3 = {
    after = [ "seaweedfs.service" ];
    requires = [ "seaweedfs.service" ];
  };

  # niks3 control server vhost
  services.nginx.virtualHosts.${niks3URL} = {
    useACMEHost = "blakehaug.com";
  };

  # reverse proxy to the seaweedfs s3 bucket
  services.nginx.virtualHosts.${cacheURL} = {
    useACMEHost = "blakehaug.com";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8333/nixcache/";
      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [
    cacheURL
    niks3URL
  ];

  networking.firewall.allowedTCPPorts = [ 8333 ];
}
