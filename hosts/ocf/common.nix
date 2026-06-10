{
  config,
  lib,
  ...
}:

{
  imports = [ ../../modules/pkgs-config.nix ];

  home.username = "blakeh";
  home.homeDirectory = "/home/b/bl/blakeh";

  services.ssh-agent.enable = true;

  programs.ssh.settings."*".identityFile = lib.mkForce "~/.ssh/id_ed25519_sk.pub";

  programs.git.settings.user.signingkey =
    lib.mkForce "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SKIP_OCF_ZSHRC = "1";
  };
}
