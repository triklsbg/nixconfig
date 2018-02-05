# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidiaDriver = "nouveau";

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../profiles/common.nix
      ../../profiles/graphical-desktop.nix
      ../../profiles/laptop.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_4_14;

  hardware.bluetooth.enable = true;

  services.xserver.synaptics.enable = true;
  # Make trackpad act as scroll wheel
  services.xserver.synaptics.additionalOptions = ''
    Option "LeftEdge"  "1"
    Option "RightEdge"  "2"
    Option "VertEdgeScroll"  "1"
    Option "AreaTopEdge"  "2500"
  '';

  #  Bumblebee has issues with tearing and crashes
  #  Power use is good enough without it anyway
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau vaapiIntel ];
  hardware.bumblebee.enable = true;
  hardware.bumblebee.connectDisplay = true;
  hardware.bumblebee.driver = nvidiaDriver;
  services.xserver.videoDrivers = [ "modesetting" ];
  boot.kernelParams = [ "i915.enable_psr=1" ];

  # Touch screen in firefox
  environment.variables.MOZ_USE_XINPUT2 = "1";

  networking.hostName = "gari";
  boot.zfs.enableUnstable = true;
  services.zfs.autoScrub.enable = true;

  networking.hostId = "a8c06607";
  networking.networkmanager.enable = true;

  fileSystems."/".options = [ "noatime" "nodiratime" ];
  fileSystems."/tmp" = {
    mountPoint = "/tmp";
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "nosuid" "nodev" "relatime" ];
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking.firewall.allowedTCPPorts = [ 51418 ];

  system.stateVersion = "18.03"; # Did you read the comment?

}
