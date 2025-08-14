#!/bin/bash

set -e

# Configuração do kubeadm com subnet padrão do Calico
cat > kubeadm-config.yml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 172.89.0.11
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
networking:
  podSubnet: 192.168.0.0/16
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF

# Reset para evitar conflitos (opcional)
#sudo kubeadm reset -f
#sudo ip link delete cni0 || true
#sudo ip link delete flannel.1 || true
#sudo systemctl restart kubelet

# Inicializa cluster
sudo kubeadm init --config kubeadm-config.yml

# Configuração do kubectl para o usuário atual
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Aplica Calico (subnet padrão)
CALICO_VERSION=v3.27.2
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml

# Gera join command para workers
kubeadm token create --print-join-command > /vagrant/join-command.sh
chmod +x /vagrant/join-command.sh

# Copia kubeconfig para /vagrant
sudo cp /etc/kubernetes/admin.conf /vagrant/kubeconfig
chmod +x /vagrant/kubeconfig

echo "Cluster inicializado com Calico (subnet padrão 192.168.0.0/16). DNS e rede de pods devem funcionar corretamente."