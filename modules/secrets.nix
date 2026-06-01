{
  config,
  inputs,
  ...
}:

let
  hostkeys = {
    ronri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46UqcVxkdL8TeUiZBID7Tz3wjVhPw1SstvfH1hjyrR";
    ito = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhtJOUxFnQicln/5h268GjBZbrRmFBv7xpa/nZ0JNwe";
    kako = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND/3tpoHWqbTw8DPBwmj1yq2LbPvZCiP1UG9+RHQAc+";
    hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFhFCahlkwdSAFyaemA8G6lYz3fnPJMP0da4cQyIyoy";
  };
in
{
  imports = [ ];

  age.rekey = {
    hostPubkey = hostkeys.${config.networking.hostName};
    masterIdentities = [
      ../secrets/master-identities/yubikey-primary.pub
      ../secrets/master-identities/yubikey-backup.pub
    ];
    storageMode = "local";
    localStorageDir = inputs.self + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
