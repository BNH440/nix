{
  ...
}:

let
  listenAddress = "127.0.0.1:8081";
  publicURL = "nixcache.blakehaug.com";
in
{
  imports = [ ];

  services = {
    atticd = {
      enable = true;
      settings = {
        listen = listenAddress;
        chunking = {
          nar-size-threshold = 64 * 1024;
          min-size = 16 * 1024;
          avg-size = 64 * 1024;
          max-size = 256 * 1024;
        };
      };
      environmentFile = "/root/.attic-env-file";
    };
  };

  age.secrets.attic-env-file = {
    rekeyFile = ../../secrets/attic-env.age;
    path = "/root/.attic-env-file";
    mode = "0400";
    owner = "root";
  };

  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts = {
      "${publicURL}" = {
        useACMEHost = "blakehaug.com";
        forceSSL = true;
        locations."/".proxyPass = "http://${listenAddress}";
      };
    };
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];
}
