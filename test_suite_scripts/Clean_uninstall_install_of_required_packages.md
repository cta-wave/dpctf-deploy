### Clean uninstall/Install of required packages.

The following is a step by step Guide to uninstall and reinstall Linux, Windows WSL, and docker-ce-cli on an undated Windows 11 platform. This assumes Docker Desktop was never installed. 

1:48 PM
Claude responded: Uninstall
Uninstall
Step 1 — Shut Down WSL
In elevated PowerShell:

powershell
```
wsl --shutdown
```
Step 2 — Unregister & Destroy the Distro
powershell

```
wsl --list --verbose
wsl --unregister Ubuntu
```
Step 3 — Remove WSL2
powershell
```
winget uninstall Microsoft.WSL

dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
```
Step 4 — Clean Residual Files
powershell

```
Remove-Item "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.wslconfig" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.docker" -Recurse -Force -ErrorAction SilentlyContinue
```

Step 5 — Reboot
powershell
```
Restart-Computer
```
Step 6 — Verify Clean
powershell
```
wsl --list
```
### Expected: "Windows Subsystem for Linux has no installed distributions"
## Reinstall WSL2 and Ubuntu
Step 1 — Install WSL2 and Ubuntu
In elevated PowerShell:
powershell

```
wsl --install
```
Reboot when prompted. On first Ubuntu launch, create your username and password.

***You may need to install 'Ununtu 24.04 LTS'. Follow instructions to install it if Ubuntu fails to start from the Start menu or run.***
```
wsl --install -d Ubuuntu-24.04 
```

Step 2 — Update Ubuntu
Inside the Ubuntu terminal:

bash
```
	sudo apt update && sudo apt upgrade -y
```
Step 3 — Install Docker CE Prerequisites

bash
```
sudo apt install ca-certificates curl -y

sudo install -m 0755 -d /etc/apt/keyrings
    
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
```    
Step 4 — Install Docker CE
bash

```
	sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```
Step 5 — Enable systemd
Required for Docker CE to run as a service in WSL2.

bash
```
sudo tee /etc/wsl.conf <<EOF
[boot]
systemd=true
EOF
```    
Then from PowerShell:

powershell

```
wsl --shutdown
wsl
```

Step 6 — Start & Enable Docker Service
Back in the Ubuntu terminal:

bash

```
sudo systemctl enable docker
sudo systemctl start docker
```
Step 7 — Add User to Docker Group
bash

```
sudo usermod -aG docker $USER
newgrp docker
```
Step 8 — Verify & Login
bash
```
docker --version
docker run hello-world
docker login
```