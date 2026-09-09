{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.niks3-db;
in
{
  options.niks3-db = {
    enable = lib.mkEnableOption "seaweedfs for niks3";
    url = lib.mkOption {
      type = lib.types.str;
    };
    port = lib.mkOption {
      type = lib.types.port;
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
            "s3-access-key:${cfg.niks3-s3-access-key}"
            "s3-secret-key:${cfg.niks3-s3-secret-key}"
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
            -ip=${cfg.url} \
            -ip.bind=:: \
            -s3.port=${toString cfg.port} \
            -volume.max=300 \
            -s3.config=/var/lib/seaweedfs/s3.json
        '';
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}
