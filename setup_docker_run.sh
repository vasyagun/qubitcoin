#!/bin/bash

set -e

WALLET="$1"
POOL="$2"

if [[ -z "$WALLET" || -z "$POOL" ]]; then
  echo "Usage: $0 <WALLET_ADDRESS> <POOL_ADDRESS>"
  echo "Example:"
  echo "./setup_docker_run.sh bc1qr7... qubitcoin.luckypool.io:8611"
  exit 1
fi

# --- УСТАНОВКА DOCKER ---
if ! command -v docker &> /dev/null; then
  echo "[*] Docker не найден. Устанавливаю..."

  if [[ -f /etc/debian_version ]]; then
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    echo "[!] Система не поддерживается. Установите Docker вручную."
    exit 1
  fi
fi

# --- УСТАНОВКА NVIDIA CONTAINER TOOLKIT ---
if ! docker info | grep -q "Runtimes: nvidia"; then
  echo "[*] Устанавливаю NVIDIA Container Toolkit..."

  # Очистка возможных конфликтов
  sudo rm -f /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo rm -f /etc/apt/sources.list.d/nvidia-docker.list
  sudo rm -f /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

  distribution=$(. /etc/os-release; echo $ID$VERSION_ID)

  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

  curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list \
    | sed 's#deb #deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] #' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  sudo apt-get update
  sudo apt-get install -y nvidia-docker2
  sudo systemctl restart docker
fi

# --- ЗАПУСК КОНТЕЙНЕРА ---
echo "[*] Загружаю и запускаю образ vasyagun/qubitcoin-miner..."
docker pull vasyagun/qubitcoin-miner

docker run --rm --gpus all \
  -e WALLET="$WALLET" \
  -e POOL="$POOL" \
  vasyagun/qubitcoin-miner
