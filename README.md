# Homelab

NixOS configuration for a home k3s cluster.

## Structure

- `modules/` — NixOS modules (e.g. `k3s-control-plane.nix`)
- `tests/` — NixOS VM integration tests
- `flake.nix` — flake outputs: modules and checks

## Usage

Import a module in your NixOS configuration:

```nix
{
  inputs.homelab.url = "github:mattjmorrison/homelab";

  outputs = { self, homelab, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      modules = [ homelab.nixosModules.k3s-control-plane ];
    };
  };
}
```

## Running Tests

```sh
make check
```

If `make` is not in PATH:

```sh
nix-shell -p gnumake --run "make check"
```
