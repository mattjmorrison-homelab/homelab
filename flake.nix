{
  description = "Homelab k3s cluster configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules = {
        k3s-control-plane = import ./modules/k3s-control-plane.nix;
      };

      checks.${system} = {
        k3s-control-plane = pkgs.testers.runNixOSTest (import ./tests/k3s-control-plane.nix { inherit self; });
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.gnumake ];
      };
    };
}
