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

# Установка Docker, если не установлен
if ! command -v docker &> /dev/null; then
  echo "[*] Docker не найден. Устанавливаю..."

  if [[ -f /etc/debian_version ]]; then
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    echo "Поддерживаются только системы на базе Debian/Ubuntu. Установите Docker вручную."
    exit 1
  fi
fi

# Проверка NVIDIA Toolkit
if ! docker info | grep -q "Runtimes: nvidia"; then
  echo "[*] Устанавливаю NVIDIA Container Toolkit..."
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list |
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  sudo apt update
  sudo apt install -y nvidia-docker2
  sudo systemctl restart docker
fi

# Запуск
echo "[*] Запуск майнера..."
docker run --rm --gpus all \
  -e WALLET="$WALLET" \
  -e POOL="$POOL" \
  vasyagun/qubitcoin-miner
