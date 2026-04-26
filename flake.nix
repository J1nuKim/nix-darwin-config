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
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "@admin" ];
          max-jobs = 2;
          cores = 4;
          min-free = 10 * 1024 * 1024 * 1024;
          max-free = 20 * 1024 * 1024 * 1024;
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
              darwin-builder.memorySize = 4 * 1024;
              cores = 4;
            };
          };
        };
      };
      security.pam.services.sudo_local.touchIdAuth = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
