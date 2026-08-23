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

  # 53/tcp,udp: CoreDNS (cluster DNS, queried by pods and nodes)
  # 6443/tcp: k3s API server, reached by workers and external clients
  # 10250/tcp: kubelet API (node-to-node)
  # 8472/udp: flannel VXLAN (node-to-node)
  networking.firewall.allowedTCPPorts = [ 53 6443 8080 443 10250 ];
  networking.firewall.allowedUDPPorts = [ 53 8472 ];

  # Clamp TCP MSS to PMTU on all forwarded traffic. Some external endpoints
  # (e.g. Azure Front Door IPs) blackhole ICMP fragmentation-needed messages,
  # so PMTUD never kicks in and oversized segments just get dropped. This
  # affects both cross-node pod-to-pod traffic over the flannel.1 VXLAN
  # overlay and pod-to-internet traffic, which on this node (imac, the
  # cluster's only schedulable node) egresses via the physical NIC with
  # SNAT/MASQUERADE and never touches flannel.1 at all. The rule is left
  # unscoped (no -o interface match) rather than hardcoded to either
  # interface, so it covers both paths.
  networking.firewall.extraCommands = ''
    iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  '';
}
