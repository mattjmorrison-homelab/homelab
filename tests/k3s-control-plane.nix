{ self }: {
  name = "k3s-control-plane";

  nodes.machine = {
    imports = [ self.nixosModules.k3s-control-plane ];
    virtualisation.memorySize = 2048;
  };

  testScript = ''
    with subtest("k3s service starts"):
        machine.wait_for_unit("k3s.service")

    with subtest("kubectl can list nodes"):
        machine.succeed("kubectl get nodes")

    with subtest("kubeconfig is readable by non-root"):
        machine.succeed("su -s /bin/sh nobody -c 'cat /etc/rancher/k3s/k3s.yaml'")

    with subtest("k9s is installed"):
        machine.succeed("k9s version")

    with subtest("KUBECONFIG is set"):
        machine.succeed("test -n \"$KUBECONFIG\"")
        machine.succeed("test -r \"$KUBECONFIG\"")

    with subtest("port 6443 is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep 6443")

    with subtest("port 53 TCP is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep 53")

    with subtest("port 53 UDP is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep udp.*53 || iptables -L nixos-fw -n | grep 53")

    with subtest("port 8080 TCP is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep 8080")

    with subtest("port 443 is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep -w 443")

    with subtest("port 8472 UDP is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep udp.*8472 || iptables -L nixos-fw -n | grep 8472")

    with subtest("TCP MSS is clamped to PMTU on flannel.1 forwarded traffic"):
        machine.succeed("iptables -t mangle -L FORWARD -n -v | grep -i flannel.1 | grep -i TCPMSS")

    with subtest("port 10250 TCP is open in firewall"):
        machine.succeed("iptables -L nixos-fw -n | grep 10250")
  '';
}
