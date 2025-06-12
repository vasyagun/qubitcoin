# qubitcoin

#qubitcoin

1)
```
sudo apt update && sudo apt upgrade -y
```

2)
```
sudo apt install -y libevent-dev libzmq5 wget curl git build-essential
```

2.1) Если при вводе этих команд не выводятся данные о драйвере, доступной карте и версии toolkit. То делаем шаги 4-6, если все уже установлено, то идем к шагу 7
```
nvcc --version
nvidia-smi
```

3)
```
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-cuda.gpg
echo "deb [signed-by=/usr/share/keyrings/nvidia-cuda.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" | sudo tee /etc/apt/sources.list.d/cuda.list
```

4)
```
sudo apt update && sudo apt upgrade -y
```

5)
```
sudo apt install -y cuda
```

6)
```
apt install nvidia-cuda-toolkit
```
