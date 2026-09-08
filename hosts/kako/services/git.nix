{
  config,
  lib,
  ...
}:

let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  rootDomain = config.web.rootDomain;
  publicURL = "git.${rootDomain}";
in
{
  age.secrets.forgejo-admin-password = {
    owner = "forgejo";
    group = "forgejo";
    mode = "600";
    rekeyFile = ../../../secrets/forgejo-admin-password.age;
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = publicURL;
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 3000;
      };
      service.DISABLE_REGISTRATION = true;
      server.SSH_PORT = lib.head config.services.openssh.ports;
    };
  };
  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe cfg.package} admin user";
      pwd = config.age.secrets.forgejo-admin-password;
      user = "blakeh";
    in
    ''
      ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      ## uncomment this line to change an admin user which was already created
      # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
    ''; # source: https://wiki.nixos.org/wiki/Forgejo#Ensure_users

  # NGINX config
  services.nginx.virtualHosts."${publicURL}" = {
    useACMEHost = rootDomain;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 512M;
    '';
    locations."/".proxyPass = "http://127.0.0.1:${toString srv.HTTP_PORT}";
  };
  security.acme.certs."${rootDomain}".extraDomainNames = [ publicURL ];
}
