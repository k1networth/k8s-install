#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# install packages
set -e

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl containerd
sudo apt-mark hold kubelet kubeadm kubectl

# activate specific modules
# overlay — The overlay module provides overlay filesystem support, which Kubernetes uses for its pod network abstraction
# br_netfilter — This module enables bridge netfilter support in the Linux kernel, which is required for Kubernetes networking and policy.
sudo modprobe br_netfilter
sudo modprobe overlay

# enable packet forwarding, enable packets crossing a bridge are sent to iptables for processing
cat <<EOF | sudo tee -a /etc/sysctl.conf
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
EOF
sudo sysctl -p /etc/sysctl.conf

# Configure containerd to use systemd as cgroup driver
sudo mkdir -p /etc/containerd
sudo tee /etc/containerd/config.toml > /dev/null <<EOF
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
   [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF

sudo systemctl restart containerd

echo "Kubernetes components have been installed and configured successfully."
