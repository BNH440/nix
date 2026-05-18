{
  config,
  pkgs,
  inputs,
  ...
}:

let
  publicURL = "nixcache.blakehaug.com";
  githubRepo = "BNH440/nix";
  niks3Pkgs = inputs.niks3.packages.${pkgs.system};
  seaweedfsHost = "${config.networking.hostName}.${config.networking.domain}";
in
{
  imports = [ ];

  age.secrets.niks3-auth-token.owner = "niks3";
  age.secrets.niks3-auth-token.group = "niks3";
  age.secrets.niks3-auth-token.mode = "0400";

  age.secrets.niks3-signing-key = {
    rekeyFile = ../../secrets/niks3-signing-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-access-key = {
    rekeyFile = ../../secrets/niks3-s3-access-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-secret-key = {
    rekeyFile = ../../secrets/niks3-s3-secret-key.age;
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
        -ip=${seaweedfsHost} \
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
      endpoint = "${seaweedfsHost}:8333";
      bucket = "nixcache";
      useSSL = false;
      accessKeyFile = config.age.secrets.niks3-s3-access-key.path;
      secretKeyFile = config.age.secrets.niks3-s3-secret-key.path;
    };

    apiTokenFile = config.age.secrets.niks3-auth-token.path;
    signKeyFiles = [ config.age.secrets.niks3-signing-key.path ];
    cacheUrl = "https://${publicURL}";

    oidc.providers.github = {
      issuer = "https://token.actions.githubusercontent.com";
      audience = "https://${publicURL}";
      boundClaims = {
        repository = [ githubRepo ];
      };
    };

    readProxy.enable = true;

    nginx = {
      enable = true;
      domain = publicURL;
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

  services.nginx.virtualHosts.${publicURL} = {
    useACMEHost = "blakehaug.com";
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];

  networking.firewall.allowedTCPPorts = [ 8333 ];
}
