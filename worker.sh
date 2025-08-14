#!/bin/bash
set -e

MASTER_IP="172.89.0.11"
JOIN_FILE="/vagrant/join-command.sh"

echo "Iniciando provisionamento do worker..."

# Aguarda o join-command existir
while [ ! -f "$JOIN_FILE" ]; do
    echo "Aguardando join-command.sh ser criado no master..."
    sleep 5
done

# Aguarda a porta 6443 do master estar aberta
until nc -z $MASTER_IP 6443 >/dev/null 2>&1; do
    echo "Aguardando API Server do master ($MASTER_IP:6443) ficar disponível..."
    sleep 3
done

echo "API Server acessível e join-command disponível. Executando join..."
bash "$JOIN_FILE"

echo "Worker conectado ao cluster com sucesso!"