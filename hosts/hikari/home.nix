{
  pkgs,
  ...
}:

let
  openssh-sk-standalone = import ./pkgs/openssh-sk-standalone.nix { inherit pkgs; };
in
{
  imports = [
    ../../home/default.nix
    ./restic/home.nix
  ];

  # add antigravity only on graphical machines
  home.packages = [ pkgs.unstable.antigravity-cli ];

  home.sessionPath = [
    "/usr/local/bin"
    "/Users/blakeh/scripts"
    "/Applications/Docker.app/Contents/Resources/bin/"
  ];

  home.shellAliases = {
    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    python = "python3";
    newrepo = "gh repo create --private --source=. --remote=origin";
    bu = "brew update && brew upgrade";
    qr = "kiro-cli restart";
    switch = "cd ~/.nixos && git pull && nh darwin switch && cd -";
  };

  # add fido2 support for ssh
  programs.ssh.extraConfig = ''
    SecurityKeyProvider ${openssh-sk-standalone}/lib/sk-libfido2.dylib
  '';

  # home.sessionVariables.SSH_SK_PROVIDER = "${openssh-sk-standalone}/lib/sk-libfido2.dylib";
}
