{
  config,
  ...
}:

let
  publicURL = "nixcache.blakehaug.com";
in
{
  imports = [ ];

  age.secrets.harmonia-secret.rekeyFile = ../../secrets/harmonia-secret.age;

  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.age.secrets.harmonia-secret.path ];
  };

  services.nginx.virtualHosts."${publicURL}" = {
    useACMEHost = "blakehaug.com";
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:5000;
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];
}
