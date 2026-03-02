#!/data/data/com.termux/files/usr/bin/bash
#
# Ubuntu VM Complete Setup Script
# ================================
# FULLY AUTOMATED - NO PROMPTS
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

VM_DIR="$HOME/storage/shared/ubuntu-vm"
DISK="$VM_DIR/ubuntu-disk.qcow2"
CLOUD_IMG="$VM_DIR/ubuntu-cloud.img"
CLOUD_INIT_ISO="$VM_DIR/cloud-init.iso"
SHARE_DIR="$HOME/ubuntu_share"

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Ubuntu VM - Automated Setup                ║${NC}"
echo -e "${GREEN}║     Maximum Performance + Data Safety          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check QEMU
if ! command -v qemu-system-aarch64 &> /dev/null; then
    echo -e "${RED}QEMU not installed!${NC}"
    echo "Run: pkg install qemu-system-aarch64"
    exit 1
fi
echo -e "${GREEN}✓${NC} QEMU installed"

# Check UEFI
UEFI="$PREFIX/share/qemu/edk2-aarch64-code.fd"
if [ ! -f "$UEFI" ]; then
    echo -e "${RED}UEFI firmware not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} UEFI firmware found"

# Create directories
mkdir -p "$VM_DIR" "$SHARE_DIR" "$VM_DIR/cloud-init" "$VM_DIR/backups"
echo -e "${GREEN}✓${NC} Directories created"

# Check cloud image
if [ ! -f "$CLOUD_IMG" ]; then
    echo -e "${YELLOW}Downloading Ubuntu 24.04 LTS ARM64...${NC}"
    wget -q --show-progress "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img" -O "$CLOUD_IMG"
fi
echo -e "${GREEN}✓${NC} Cloud image ready"

# Check disk image
if [ ! -f "$DISK" ]; then
    echo -e "${YELLOW}Creating 25GB disk image...${NC}"
    qemu-img create -f qcow2 "$DISK" 25G
fi
echo -e "${GREEN}✓${NC} Disk image ready"

# Create cloud-init ISO (always regenerate with latest config)
echo -e "${YELLOW}Generating cloud-init ISO...${NC}"

# Create user-data (fully automated)
cat > "$VM_DIR/cloud-init/user-data" << 'USERDATA'
#cloud-config
# FULLY AUTOMATED - NO PROMPTS

chpasswd:
  list: |
    root:root
  expire: false

ssh_pwauth: true

users:
  - name: root
    lock_passwd: false
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL

packages:
  - openssh-server
  - curl
  - wget
  - git
  - vim
  - htop
  - tmux
  - python3
  - nodejs
  - npm
  - net-tools
  - rsync
  - jq
  - tree
  - ncdu
  - build-essential
  - ca-certificates

write_files:
  - path: /etc/ssh/sshd_config
    content: |
      Port 22
      PermitRootLogin yes
      PasswordAuthentication yes
      PubkeyAuthentication yes
      PrintMotd no
      PrintLastLog no
      UseDNS no
      ClientAliveInterval 60
      AllowTcpForwarding yes
      Subsystem sftp /usr/lib/openssh/sftp-server
    append: false

  - path: /usr/local/bin/dev-on
    content: |
      #!/bin/bash
      echo "========================================"
      echo "     Ubuntu VM - Services Status"
      echo "========================================"
      pgrep -x sshd > /dev/null && echo "  [OK] SSH" || echo "  [FAIL] SSH"
      pgrep -f code-server > /dev/null && echo "  [OK] VS Code" || echo "  [FAIL] VS Code"
      pgrep -f filebrowser > /dev/null && echo "  [OK] File Browser" || echo "  [FAIL] File Browser"
      pgrep -f ttyd > /dev/null && echo "  [OK] Web Terminal" || echo "  [FAIL] Web Terminal"
    permissions: "0755"

  - path: /usr/local/bin/ssh-start
    content: |
      #!/bin/bash
      service ssh start 2>/dev/null || true
      command -v code-server > /dev/null 2>&1 && pkill -f code-server 2>/dev/null; nohup code-server --auth none --bind-addr 0.0.0.0:8080 /root >/dev/null 2>&1 &
      command -v filebrowser > /dev/null 2>&1 && pkill -f filebrowser 2>/dev/null; nohup filebrowser -p 9000 -r /root -d /srv/filebrowser.db >/dev/null 2>&1 &
      command -v ttyd > /dev/null 2>&1 && pkill -f ttyd 2>/dev/null; nohup ttyd -p 7681 bash >/dev/null 2>&1 &
      echo "All services started!"
    permissions: "0755"

  - path: /usr/local/bin/ssh-stop
    content: |
      #!/bin/bash
      pkill -f ttyd 2>/dev/null; pkill -f filebrowser 2>/dev/null; pkill -f code-server 2>/dev/null; pkill sshd 2>/dev/null
      echo "All services stopped!"
    permissions: "0755"

  - path: /usr/local/bin/sysinfo
    content: |
      #!/bin/bash
      echo "========================================"
      echo "     System Information"
      echo "========================================"
      echo "  Hostname: $(hostname)"
      echo "  Kernel: $(uname -r)"
      echo "  CPU: $(nproc) cores"
      echo "  Memory: $(free -h | awk 'NR==2{print $3" / "$2}')"
      echo "  Disk: $(df -h / | awk 'NR==2{print $3" / "$2}')"
      echo "  IP: $(hostname -I | awk '{print $1}')"
    permissions: "0755"

  - path: /usr/local/bin/mount-share
    content: |
      #!/bin/bash
      mkdir -p /shared_mount
      mount -t 9p -o trans=virtio,version=9p2000.L,rw shared_mount /shared_mount 2>/dev/null && echo "Mounted" || echo "Failed"
    permissions: "0755"

  - path: /etc/motd
    content: |
      ========================================
           Ubuntu VM - Ready to Use
      ========================================
      Username: root | Password: root
      SSH: ssh -p 2222 root@localhost
      ========================================
    permissions: "0644"

runcmd:
  - timedatectl set-timezone UTC || true
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  - DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server curl wget git vim htop tmux python3 nodejs npm net-tools rsync jq tree ncdu build-essential ca-certificates
  - ssh-keygen -A
  - service ssh start || systemctl start ssh || true
  - service ssh restart || systemctl restart ssh || true
  - wget -q https://github.com/filebrowser/filebrowser/releases/download/v2.31.2/linux-arm64-filebrowser.tar.gz -O /tmp/fb.tar.gz || true
  - tar -xzf /tmp/fb.tar.gz -C /usr/local/bin/ 2>/dev/null || true
  - chmod +x /usr/local/bin/filebrowser 2>/dev/null || true
  - mkdir -p /srv && filebrowser config init -d /srv/filebrowser.db 2>/dev/null || true
  - filebrowser users add root root -d /srv/filebrowser.db --perm.admin 2>/dev/null || true
  - wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.aarch64 -O /usr/local/bin/ttyd 2>/dev/null || true
  - chmod +x /usr/local/bin/ttyd 2>/dev/null || true
  - curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone 2>/dev/null || true
  - /usr/local/bin/ssh-start
  - echo "shared_mount /shared_mount 9p trans=virtio,version=9p2000.L,rw 0 0" >> /etc/fstab || true
  - apt-get clean || true
  - rm -rf /tmp/* || true

final_message: "Ubuntu VM Ready! root:root | SSH: ssh -p 2222 root@localhost"
USERDATA

echo "meta-data: {}" > "$VM_DIR/cloud-init/meta-data"

cd "$VM_DIR/cloud-init"
xorriso -as mkisofs -volid CIDATA -joliet -rock -output "$CLOUD_INIT_ISO" . >/dev/null 2>&1
cd - >/dev/null

echo -e "${GREEN}✓${NC} Cloud-init ISO ready"

# Add bash aliases (only if not present)
if ! grep -q "alias ubuntu=" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'BASHRC'

# Ubuntu VM aliases
alias ubuntu='~/ubuntu-linux'
alias ubuntuvms='~/ubuntu-linux'
alias ubuntu-backup='~/ubuntu-vm-backup'
alias ubuntu-restore='~/ubuntu-vm-restore'
alias ubuntu-health='~/ubuntu-vm-health'
BASHRC
    source ~/.bashrc
fi
echo -e "${GREEN}✓${NC} Bash aliases configured"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Setup Complete!                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}To start Ubuntu VM:${NC}"
echo "  ubuntu"
echo ""
echo -e "${BLUE}Default Credentials:${NC}"
echo "  Username: root"
echo "  Password: root"
echo ""
echo -e "${BLUE}Access from Termux:${NC}"
echo "  SSH:        ssh -p 2222 root@localhost"
echo "  VS Code:    http://localhost:8080"
echo "  File Browser: http://localhost:9000"
echo "  Web Terminal: http://localhost:7681"
echo ""
echo -e "${BLUE}Shared folder:${NC}"
echo "  Host: ~/ubuntu_share"
echo "  VM:   /shared_mount"
echo ""
echo -e "${MAGENTA}════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}First boot takes 2-5 minutes (auto-setup)${NC}"
echo -e "${YELLOW}All services start automatically!${NC}"
echo -e "${YELLOW}NO PROMPTS - Fully automated!${NC}"
echo -e "${MAGENTA}════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Exit QEMU: Ctrl+A then X${NC}"
echo ""
