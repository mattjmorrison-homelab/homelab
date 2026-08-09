{ pkgs, ... }: {
  services.k3s = {
    enable = true;
    role = "server";
    # k3s defaults to 0600 (root-only); 0644 lets non-root users run kubectl
    extraFlags = [ "--write-kubeconfig-mode=0644" ];
  };

  environment.systemPackages = [ pkgs.k9s ];

  # Point tools (kubectl, k9s) at the k3s kubeconfig without per-user setup
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  # Workers and external clients reach the API server on this port
  networking.firewall.allowedTCPPorts = [ 53 6443 8080 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
