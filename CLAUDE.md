# Homelab

## Rules

- Do not change any files unless explicitly asked to

## Running Tests

If `make` is not in PATH, run it via nix-shell:

    nix-shell -p gnumake --run "make check"
