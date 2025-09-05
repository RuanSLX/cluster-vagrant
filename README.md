# cluster-vagrant

Projeto para criação de um cluster Kubernetes (master + workers) utilizando **Vagrant** e scripts em **Shell**.

## Estrutura

- **VagrantFile** – define as VMs e provisioning.
- **common.sh** – funções e variáveis comuns.
- **master.sh** – configuração do nó mestre.
- **worker.sh** – configuração dos nós workers.
- **setup-kubelet.sh** – instalação e configuração do kubelet.

## Pré-requisitos

- [Vagrant](https://www.vagrantup.com/) (v2.x+)
- [VirtualBox](https://www.virtualbox.org/) ou outro provedor compatível

## Como usar

```bash
# Clonar o repositório
git clone https://github.com/RuanSLX/cluster-vagrant.git
cd cluster-vagrant

# Subir o cluster
vagrant up

# Acessar o nó master
vagrant ssh master
kubectl get nodes
