# NixOS configuration for niri + Noctalia shell test VM
# Targets aarch64-linux running in QEMU on an Apple Silicon Mac
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # ── Boot & VM plumbing ──────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel & initrd modules for QEMU/virtio
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "virtio_gpu"
  ];
  boot.kernelModules = [ "virtio_gpu" ];

  # Filesystem — single root on virtio block device
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  # ── QCOW2 image builder ────────────────────────────────────────────
  system.build.qcow2Image = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    diskSize = 16384; # 16 GB
    format = "qcow2";
    partitionTableType = "efi";
  };

  # ── VM settings (for `nixos-rebuild build-vm` / `nix build .#vm`) ──
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      qemu.options = [
        "-device virtio-gpu-pci"
        "-display default,show-cursor=on"
      ];
    };
  };

  # ── Networking ──────────────────────────────────────────────────────
  networking.hostName = "niri-test";
  networking.networkmanager.enable = true;

  # ── Locale / timezone ──────────────────────────────────────────────
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Nix settings ───────────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # ── Niri WM ────────────────────────────────────────────────────────
  # The niri NixOS module handles polkit, portals, dconf, opengl, etc.
  programs.niri = {
    enable = true;
    # Use the overlay-provided niri-stable
  };

  # Apply the niri overlay so pkgs.niri-stable is available
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # ── Display / greeter ──────────────────────────────────────────────
  # Use greetd + tuigreet for a lightweight TTY greeter
  # that launches niri-session automatically
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Auto-login as test user, launching niri
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
      # For testing convenience: auto-login the test user
      initial_session = {
        command = "niri-session";
        user = "test";
      };
    };
  };

  # ── Graphics ────────────────────────────────────────────────────────
  hardware.graphics.enable = true;

  # ── Audio (PipeWire) ────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── Test user (no password, auto-login) ─────────────────────────────
  users.users.test = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
    ];
    # Empty password for testing convenience
    initialPassword = "test";
    shell = pkgs.bash;
  };

  # Allow passwordless sudo for the test user
  security.sudo.wheelNeedsPassword = false;

  # ── System packages ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Core desktop utilities
    foot # terminal emulator (lightweight, Wayland-native)
    fuzzel # application launcher
    mako # notification daemon (fallback, noctalia provides its own)
    wl-clipboard # clipboard utilities
    grim # screenshot
    slurp # screen region selection
    brightnessctl

    # System tools
    vim
    htop
    git
    wget
    file

    # Noctalia shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # ── Fonts ───────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      inter
      meslo-lgs-nf
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Fira Code" ];
        sansSerif = [ "Inter" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # ── Home Manager ────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.test = ./home.nix;
  };

  # ── Misc ────────────────────────────────────────────────────────────
  # Enable dbus (needed for many desktop things)
  services.dbus.enable = true;

  system.stateVersion = "26.05";
}
