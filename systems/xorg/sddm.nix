{ config, pkgs, ... }:

{
  services.xserver.displayManager = {
    sddm.enable = true;
    defaultSession = "none+bspwm";
  };
}
