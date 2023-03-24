{ nixpkgs
, home-manager
, ...
}:

{ system
, machine
, user
, hashedPassword
, resolution
, dpi
}:

let
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  stateVersion = "22.11";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    home-manager.nixosModules.default

    {
      config._module.args = {
        inherit user resolution dpi;
      };
    }

    ({ config, lib, pkgs, home-manager, ... }: {
      # Using already configured sets of pkgs.
      imports = import ../conf;

      # Overlays to extend lib.
      nixpkgs.overlays = [ (import ./overlays.nix) ];

      # Immutable user and no password for sudo.
      users.mutableUsers = false;
      security.sudo.wheelNeedsPassword = false;

      # Home Manager settings.
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # Single user mode.
      users.users.${user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        inherit hashedPassword;
      };
      home-manager.users.${user} = {
        xdg.enable = true;
        home.stateVersion = stateVersion;
      };
      system.stateVersion = stateVersion;
    })

    ../machines/${machine}
  ];
}
