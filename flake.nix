{
  description = "Fuck you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lobster.url = "github:justchokingaround/lobster";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lobster, nur, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        {
          nixpkgs.overlays = [ nur.overlays.default ];
        }
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ice = ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
      ];
    };
  };
}
