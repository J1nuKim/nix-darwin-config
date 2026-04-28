{
  description = " ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        vim
        git
      ];

      programs.zsh.enable = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.hostPlatform = "aarch64-darwin";

      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "@admin" ];
          max-jobs = 2;
          cores = 4;
          min-free = 10 * 1024 * 1024 * 1024;
          max-free = 20 * 1024 * 1024 * 1024;

          builders-use-substitutes = true;
          warn-dirty = false;
          keep-outputs = true;
          keep-derivations = true;

          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };

        optimise.automatic = true;

        extraOptions = ''
          extra-platforms = x86_64-darwin
        '';

        gc = {
          automatic = true;
          interval = { Weekday = 0; Hour = 2; Minute = 0; };
          options = "--delete-older-than 14d";
        };

        linux-builder = {
          enable = true;
          ephemeral = true;
          systems = [ "aarch64-linux" "x86_64-linux" ];
          maxJobs = 2;
          config = {
            virtualisation = {
              darwin-builder.diskSize = 30 * 1024;
              darwin-builder.memorySize = 6 * 1024;
              cores = 4;
            };
          };
        };
      };

      security.pam.services.sudo_local.touchIdAuth = true;

      system.primaryUser = "jinukim";
      users.users."jinukim" = {
        name = "jinukim";
        home = "/Users/jinukim";
      };

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
    };
  in
  {
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
