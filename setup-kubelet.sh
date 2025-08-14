#!/bin/bash
set -e

NODE_IP="$1"

if [ -z "$NODE_IP" ]; then
    echo "Uso: $0 <IP_DO_NODE>"
    exit 1
fi

DROPIN_DIR="/usr/lib/systemd/system/kubelet.service.d"
sudo mkdir -p "$DROPIN_DIR"
UPDATED=0

for file in "$DROPIN_DIR"/*.conf; do
    [ -f "$file" ] || continue

    if grep -q '^Environment="KUBELET_EXTRA_ARGS=' "$file"; then
        # Atualiza linha existente
        sudo sed -i "s|^Environment=\"KUBELET_EXTRA_ARGS=.*\"|Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}\"|" "$file"
        UPDATED=1
    else
        # Adiciona a linha logo após [Service]
        sudo sed -i "/^\[Service\]/a Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}\"" "$file"
        UPDATED=1
    fi
done

if [ "$UPDATED" -eq 0 ]; then
    # Nenhum arquivo conf encontrado, cria um novo drop-in
    FILE="$DROPIN_DIR/10-kubeadm.conf"
    sudo bash -c "cat > $FILE <<EOF
[Service]
Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}\"
EOF"
fi

# Atualiza /etc/default/kubelet
sudo grep -q "KUBELET_EXTRA_ARGS" /etc/default/kubelet 2>/dev/null || \
    echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" | sudo tee -a /etc/default/kubelet >/dev/null
sudo sed -i "/KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" /etc/default/kubelet

# Recarrega systemd e reinicia kubelet
sudo systemctl daemon-reexec
sudo systemctl restart kubelet

echo "Kubelet configurado com IP ${NODE_IP}."