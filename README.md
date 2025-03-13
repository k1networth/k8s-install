# k8s-install

```
# get master ip for --apiserver-advertise-address
ip a


# to access kubernetes from external network you need to additionaly set flag with external ip --apiserver-cert-extra-sans=158.160.111.211
sudo kubeadm init \
  --apiserver-advertise-address=10.128.0.28 \
  --pod-network-cidr 10.244.0.0/16


# set default kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# install cni flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml


# add worker nodes
# kubeadm token generate
# kubeadm token create <generated-token> --print-join-command --ttl=0
sudo kubeadm join 10.128.0.28:6443 --token zvxm7y.z61zq4rzaq3rtipk \
        --discovery-token-ca-cert-hash sha256:9b650e50a7a5b6261746684d033a7d6483ea5b84db8932cb70563b35f91080f7
```
