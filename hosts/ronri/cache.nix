{
  config,
  pkgs,
  inputs,
  ...
}:

let
  publicURL = "nixcache.blakehaug.com";
  atticPkgs = inputs.attic.packages.${pkgs.system};
in
{
  imports = [ ];

  age.secrets.atticd-credentials.rekeyFile = ../../secrets/atticd-credentials.age;
  services.atticd = {
    enable = true;
    package = atticPkgs.attic-server;
    environmentFile = config.age.secrets.atticd-credentials.path;
    settings = {
      listen = "[::]:8080";
      api-endpoint = "https://${publicURL}/";
      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
      chunking = {
        nar-size-threshold = 65536;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      compression = {
        type = "zstd";
      };
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "6 months";
      };
    };
  };

  services.nginx.virtualHosts."${publicURL}" = {
    useACMEHost = "blakehaug.com";
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:8080;
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      client_max_body_size 0;
    '';
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];
}
