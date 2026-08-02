SHELL := $(shell which bash)
NIX_CONFIG = experimental-features = nix-command flakes

.PHONY: test check

test: check

check:
	NIX_CONFIG="$(NIX_CONFIG)" nix build --no-link .#checks.x86_64-linux.k3s-control-plane \
		&& echo "PASS k3s-control-plane" \
		|| (NIX_CONFIG="$(NIX_CONFIG)" nix build -L --no-link .#checks.x86_64-linux.k3s-control-plane 2>&1 | \
		    (grep -E "subtest:|finished: subtest:|test script finished|Traceback|Exception" || true) | \
		    sed 's/^[^>]*> //'; exit 1)
