{
  ...
}:

let
  publicURL = "soulcraft.blakehaug.com";
in
{
  blakehaug-web.enable = true;

  services.nginx.virtualHosts."${publicURL}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
