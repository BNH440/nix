{
  pkgs,
  ...
}:

{
  # Enable OpenGL/Vulkan
  hardware.graphics.enable = true;

  # Tell Xorg and Wayland to use the Nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    nvidia-container-toolkit
    nvidia-docker
  ];

  hardware.nvidia-container-toolkit.enable = true;

  environment.variables = {
    CUDA_HOME = pkgs.cudatoolkit;
  };

  hardware.nvidia = {
    # Required for Wayland (Hyprland, COSMIC, Sway, etc.)
    modesetting.enable = true;

    # Nvidia power management. Experimental, but usually needed
    # to prevent graphical corruption after waking from sleep.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;
  };
}
