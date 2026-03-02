#!/data/data/com.termux/files/usr/bin/bash
#
# Ubuntu Termux VM - All-in-One Installer v2.0
# =============================================
# Fixed: aio=threads compatibility, proper script installation
#
# Just run: curl -L https://raw.githubusercontent.com/YOUR_USERNAME/ubuntu-termux-vm/main/install.sh | bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# URLs
REPO_URL="https://github.com/YOUR_USERNAME/ubuntu-termux-vm"
UBUNTU_MIRROR="https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"

# Directories
HOME_DIR="$HOME"
VM_DIR="$HOME_DIR/storage/shared/ubuntu-vm"
SHARE_DIR="$HOME_DIR/ubuntu_share"

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🐘  Ubuntu VM for Termux - Installer v2.0               ║"
echo "║                                                              ║"
echo "║     Run full Ubuntu 24.04 on your Android phone!             ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

setup_storage() {
    echo -e "\n${CYAN}[1/7] Setting up storage...${RESET}"
    
    if [ -d "$HOME_DIR/storage" ]; then
        echo -e "  ${GREEN}✓${RESET} Storage already configured"
    else
        termux-setup-storage 2>/dev/null || true
        echo -e "  ${GREEN}✓${RESET} Storage permission requested"
    fi
    
    mkdir -p "$VM_DIR" "$SHARE_DIR"
    echo -e "  ${GREEN}✓${RESET} Directories created"
}

update_packages() {
    echo -e "\n${CYAN}[2/7] Updating packages...${RESET}"
    
    pkg update -y 2>&1 | tail -3
    pkg upgrade -y 2>&1 | tail -3
    
    echo -e "  ${GREEN}✓${RESET} Packages updated"
}

install_dependencies() {
    echo -e "\n${CYAN}[3/7] Installing dependencies...${RESET}"
    
    pkg install qemu-system-aarch64 xorriso wget curl git openssh htop vim -y 2>&1 | tail -3
    
    echo -e "  ${GREEN}✓${RESET} Dependencies installed"
}

download_ubuntu() {
    echo -e "\n${CYAN}[4/7] Downloading Ubuntu 24.04...${RESET}"
    
    local cloud_img="$VM_DIR/ubuntu-cloud.img"
    
    if [ -f "$cloud_img" ] && [ $(stat -c%s "$cloud_img" 2>/dev/null || echo 0) -gt 100000000 ]; then
        echo -e "  ${GREEN}✓${RESET} Already downloaded"
        return 0
    fi
    
    wget -q --show-progress -O "$cloud_img" "$UBUNTU_MIRROR"
    
    local size=$(du -h "$cloud_img" | cut -f1)
    echo -e "  ${GREEN}✓${RESET} Downloaded ($size)"
}

create_disk() {
    echo -e "\n${CYAN}[5/7] Creating virtual disk...${RESET}"
    
    local disk="$VM_DIR/ubuntu-disk.qcow2"
    
    if [ -f "$disk" ]; then
        echo -e "  ${GREEN}✓${RESET} Already exists"
        return 0
    fi
    
    qemu-img create -f qcow2 "$disk" 25G >/dev/null 2>&1
    
    echo -e "  ${GREEN}✓${RESET} 25GB disk created"
}

create_cloud_init() {
    echo -e "\n${CYAN}[6/7] Creating cloud-init config...${RESET}"
    
    local ci_dir="$VM_DIR/cloud-init"
    mkdir -p "$ci_dir"
    
    cat > "$ci_dir/user-data" << 'USERDATA'
#cloud-config
chpasswd:
  list: |
    root:root
  expire: false
ssh_pwauth: true
users:
  - name: root
    lock_passwd: false
    shell: /bin/bash
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
runcmd:
  - service ssh start || systemctl start ssh || true
  - ssh-keygen -A
  - service ssh restart || systemctl restart ssh || true
  - apt-get update
  - wget -q https://github.com/filebrowser/filebrowser/releases/download/v2.31.2/linux-arm64-filebrowser.tar.gz -O /tmp/fb.tar.gz || true
  - tar -xzf /tmp/fb.tar.gz -C /usr/local/bin/ 2>/dev/null || true
  - chmod +x /usr/local/bin/filebrowser 2>/dev/null || true
  - mkdir -p /srv && filebrowser config init -d /srv/filebrowser.db 2>/dev/null || true
  - filebrowser users add root root -d /srv/filebrowser.db --perm.admin 2>/dev/null || true
  - wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.aarch64 -O /usr/local/bin/ttyd 2>/dev/null || true
  - chmod +x /usr/local/bin/ttyd 2>/dev/null || true
  - curl -fsSL https://code-server.dev/install.sh | sh 2>/dev/null || true
  - /usr/local/bin/ssh-start
  - echo "shared_mount /shared_mount 9p trans=virtio,version=9p2000.L,rw 0 0" >> /etc/fstab || true
final_message: "Ubuntu VM Ready! root:root | SSH: ssh -p 2222 root@localhost"
USERDATA

    echo "meta-data: {}" > "$ci_dir/meta-data"
    
    cd "$ci_dir"
    xorriso -as mkisofs -volid CIDATA -joliet -rock -output "$VM_DIR/cloud-init.iso" . >/dev/null 2>&1
    cd - >/dev/null
    
    echo -e "  ${GREEN}✓${RESET} Cloud-init configured"
}

install_scripts() {
    echo -e "\n${CYAN}[7/7] Installing scripts...${RESET}"
    
    # Download scripts from GitHub if not in same directory
    local script_dir="$(dirname "$(readlink -f "$0")")"
    
    # Download main scripts
    local scripts="ubuntu-linux ubuntu-vm-console ubuntu-vm-backup ubuntu-vm-health setup-ubuntu-vm.sh"
    
    for script in $scripts; do
        if [ -f "$script_dir/$script" ]; then
            cp "$script_dir/$script" "$HOME_DIR/$script"
            chmod +x "$HOME_DIR/$script"
            echo -e "  ${GREEN}✓${RESET} $script"
        else
            # Try downloading from repo
            wget -q "https://raw.githubusercontent.com/YOUR_USERNAME/ubuntu-termux-vm/main/$script" -O "$HOME_DIR/$script" 2>/dev/null && \
            chmod +x "$HOME_DIR/$script" && \
            echo -e "  ${GREEN}✓${RESET} $script (downloaded)" || \
            echo -e "  ${YELLOW}!${RESET} $script (not found)"
        fi
    done
    
    # Add aliases
    cat >> "$HOME_DIR/.bashrc" << 'BASHRC'

# Ubuntu VM aliases
alias ubuntu='~/ubuntu-linux'
alias ubuntu-console='~/ubuntu-vm-console'
alias ubuntu-backup='~/ubuntu-vm-backup'
alias ubuntu-health='~/ubuntu-vm-health'
BASHRC
    
    source "$HOME_DIR/.bashrc" 2>/dev/null || true
    
    echo -e "  ${GREEN}✓${RESET} Aliases added"
}

final_message() {
    clear
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║          🎉  INSTALLATION COMPLETE!  🎉                     ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo ""
    echo -e "${WHITE}Ubuntu VM is ready to use!${RESET}"
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${WHITE}  QUICK START GUIDE                              ${CYAN}│${RESET}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET}                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  ${GREEN}1.${RESET} Start Ubuntu VM:                          ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     ${YELLOW}ubuntu-console${RESET}                              ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     Then press ENTER on 'START VM'              ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  ${GREEN}2.${RESET} Connect via SSH (new session):           ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     ${YELLOW}ssh -p 2222 root@localhost${RESET}                  ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     Password: ${YELLOW}root${RESET}                               ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}  ${GREEN}3.${RESET} Web Services:                             ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     VS Code:      ${YELLOW}http://localhost:8080${RESET}         ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     File Browser: ${YELLOW}http://localhost:9000${RESET}         ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}     Web Terminal: ${YELLOW}http://localhost:7681${RESET}         ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${WHITE}Commands:${RESET}"
    echo -e "  ${YELLOW}ubuntu${RESET}         - Start VM"
    echo -e "  ${YELLOW}ubuntu-console${RESET} - Interactive menu"
    echo -e "  ${YELLOW}ubuntu-backup${RESET}  - Backup VM"
    echo -e "  ${YELLOW}ubuntu-health${RESET}  - Check disk health"
    echo ""
    echo -e "${DIM}First boot takes 2-5 minutes for auto-setup.${RESET}"
    echo -e "${DIM}Exit VM: Press Ctrl+A then X${RESET}"
    echo ""
    echo -e "${GREEN}Enjoy your Ubuntu VM! 🐧📱${RESET}"
    echo ""
}

# Main
setup_storage
update_packages
install_dependencies
download_ubuntu
create_disk
create_cloud_init
install_scripts
final_message
