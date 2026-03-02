#!/data/data/com.termux/files/usr/bin/bash
#
# Ubuntu Termux VM - All-in-One Installer
# ========================================
# For first-time Termux users - Fully Automated
#
# Just run: curl -L https://raw.githubusercontent.com/yourusername/ubuntu-termux-vm/main/install.sh | bash
#

set -e

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# URLs
REPO_URL="https://github.com/yourusername/ubuntu-termux-vm"
UBUNTU_MIRROR="https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"

# Directories
HOME_DIR="$HOME"
VM_DIR="$HOME_DIR/storage/shared/ubuntu-vm"
SHARE_DIR="$HOME_DIR/ubuntu_share"

# ═══════════════════════════════════════════════════════════════
# ANIMATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Progress bar
progress_bar() {
    local duration=$1
    local width=$2
    local label=$3
    
    for ((i=0; i<=100; i+=5)); do
        local filled=$((i * width / 100))
        local empty=$((width - filled))
        printf "\r${DIM}%-20s${RESET} [${GREEN}" "$label"
        for ((j=0; j<filled; j++)); do printf "█"; done
        for ((j=0; j<empty; j++)); do printf "░"; done
        printf "${RESET}] %3d%%" "$i"
        sleep $(echo "$duration / 20" | bc -l 2>/dev/null || echo "0.1")
    done
    printf "\n"
}

# Animated text
animate_text() {
    local text="$1"
    local color="${2:-$WHITE}"
    echo -ne "$color"
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep 0.02
    done
    echo -ne "$RESET\n"
}

# Success animation
success_animation() {
    echo -e "${GREEN}"
    echo "  ╔════════════════════════════════════════╗"
    echo "  ║           ✓ SUCCESS!                  ║"
    echo "  ╚════════════════════════════════════════╝"
    echo -ne "$RESET"
}

# Error animation
error_animation() {
    echo -e "${RED}"
    echo "  ╔════════════════════════════════════════╗"
    echo "  ║           ✗ ERROR                     ║"
    echo "  ╚════════════════════════════════════════╝"
    echo -ne "$RESET"
}

# ═══════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

log() {
    echo -e "${DIM}[$(date '+%H:%M:%S')]${RESET} $*"
}

step() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET} ${BOLD}$*${RESET} ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════╝${RESET}\n"
}

check_exit() {
    if [ $? -ne 0 ]; then
        error_animation
        echo -e "${RED}Failed: $*${RESET}"
        echo -e "${YELLOW}Check the error above and try again.${RESET}"
        exit 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════

welcome() {
    clear
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     🐘  Ubuntu VM for Termux - Installer            ║"
    echo "║                                                              ║"
    echo "║     Run full Ubuntu 24.04 on your Android phone!    ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo ""
    echo -e "${WHITE}Welcome! This installer will:${RESET}"
    echo ""
    echo -e "  ${GREEN}✓${RESET} Set up Termux storage"
    echo -e "  ${GREEN}✓${RESET} Update all packages"
    echo -e "  ${GREEN}✓${RESET} Install QEMU + dependencies"
    echo -e "  ${GREEN}✓${RESET} Download Ubuntu 24.04 (~500MB)"
    echo -e "  ${GREEN}✓${RESET} Create virtual disk"
    echo -e "  ${GREEN}✓${RESET} Configure auto-setup"
    echo ""
    echo -e "${DIM}Installation takes 5-10 minutes depending on internet speed.${RESET}"
    echo ""
    echo -e "${YELLOW}Press ENTER to continue, or Ctrl+C to cancel${RESET}"
    read -s
}

setup_storage() {
    step "Step 1/7: Setting up Storage"
    
    log "Requesting storage permission..."
    
    # Check if storage is already set up
    if [ -d "$HOME/storage" ]; then
        log "Storage already configured"
    else
        log "Running termux-setup-storage..."
        termux-setup-storage 2>/dev/null || true
        
        echo -e "${YELLOW}"
        echo "  ┌─────────────────────────────────────────────────┐"
        echo "  │  ALLOW STORAGE PERMISSION!                      │"
        echo "  │                                                 │"
        echo "  │  1. Tap 'Allow' on the permission popup        │"
        echo "  │  2. If no popup, run: termux-setup-storage     │"
        echo "  │  3. Then press ENTER here                      │"
        echo "  └─────────────────────────────────────────────────┘"
        echo -e "${RESET}"
        
        read -p "  Press ENTER after granting permission... "
    fi
    
    # Create directories
    log "Creating directories..."
    mkdir -p "$VM_DIR" "$SHARE_DIR"
    check_exit "Creating directories"
    
    success_animation
    echo -e "  ${GREEN}Storage configured successfully!${RESET}"
}

update_packages() {
    step "Step 2/7: Updating Packages"
    
    log "Updating package lists..."
    
    # Change repo if needed
    if ! pkg update &>/dev/null; then
        log "Changing repository..."
        termux-change-repo 2>/dev/null || true
    fi
    
    # Update
    pkg update -y 2>&1 | tail -5
    
    log "Upgrading packages..."
    pkg upgrade -y 2>&1 | tail -5
    
    success_animation
    echo -e "  ${GREEN}Packages updated!${RESET}"
}

install_dependencies() {
    step "Step 3/7: Installing Dependencies"
    
    local packages=(
        "qemu-system-aarch64"
        "xorriso"
        "wget"
        "curl"
        "git"
        "openssh"
        "htop"
        "vim"
    )
    
    log "Installing ${#packages[@]} packages..."
    echo ""
    
    for pkg_name in "${packages[@]}"; do
        printf "  ${DIM}•${RESET} Installing %-25s" "$pkg_name"
        
        pkg install "$pkg_name" -y 2>&1 | grep -E "(Downloading|Installing|Unpacking)" | tail -1 || true
        
        if [ $? -eq 0 ]; then
            printf "\r  ${GREEN}✓${RESET} %-30s installed\n" "$pkg_name"
        else
            printf "\r  ${RED}✗${RESET} %-30s failed\n" "$pkg_name"
        fi
    done
    
    success_animation
    echo -e "  ${GREEN}All dependencies installed!${RESET}"
}

download_ubuntu() {
    step "Step 4/7: Downloading Ubuntu 24.04"
    
    local cloud_img="$VM_DIR/ubuntu-cloud.img"
    
    if [ -f "$cloud_img" ] && [ $(stat -c%s "$cloud_img" 2>/dev/null || echo 0) -gt 100000000 ]; then
        log "Ubuntu image already downloaded"
        return 0
    fi
    
    log "Downloading from: $UBUNTU_MIRROR"
    echo ""
    
    # Download with progress
    wget -q --show-progress -O "$cloud_img" "$UBUNTU_MIRROR" 2>&1 &
    local pid=$!
    spinner $pid
    
    wait $pid
    
    if [ $? -eq 0 ]; then
        local size=$(du -h "$cloud_img" | cut -f1)
        success_animation
        echo -e "  ${GREEN}Ubuntu downloaded! ($size)${RESET}"
    else
        error_animation
        echo -e "  ${RED}Download failed!${RESET}"
        echo ""
        echo -e "${YELLOW}Try manual download:${RESET}"
        echo "  wget $UBUNTU_MIRROR -O $cloud_img"
        exit 1
    fi
}

create_disk() {
    step "Step 5/7: Creating Virtual Disk"
    
    local disk="$VM_DIR/ubuntu-disk.qcow2"
    
    if [ -f "$disk" ]; then
        log "Disk already exists"
        return 0
    fi
    
    log "Creating 25GB dynamic disk..."
    
    qemu-img create -f qcow2 "$disk" 25G 2>&1 &
    local pid=$!
    spinner $pid
    
    success_animation
    echo -e "  ${GREEN}Virtual disk created!${RESET}"
}

create_cloud_init() {
    step "Step 6/7: Creating Cloud-Init Config"
    
    local ci_dir="$VM_DIR/cloud-init"
    mkdir -p "$ci_dir"
    
    # Create user-data
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
    
    # Create ISO
    cd "$ci_dir"
    xorriso -as mkisofs -volid CIDATA -joliet -rock -output "$VM_DIR/cloud-init.iso" . >/dev/null 2>&1
    cd - >/dev/null
    
    success_animation
    echo -e "  ${GREEN}Cloud-init configured!${RESET}"
}

copy_scripts() {
    step "Step 7/7: Installing Scripts"
    
    local script_dir="$(dirname "$(readlink -f "$0")")"
    
    # Copy scripts
    log "Copying scripts..."
    
    for script in ubuntu-linux ubuntu-vm-console ubuntu-vm-backup ubuntu-vm-health setup-ubuntu-vm.sh; do
        if [ -f "$script_dir/$script" ]; then
            cp "$script_dir/$script" "$HOME_DIR/"
            chmod +x "$HOME_DIR/$script"
            echo -e "  ${GREEN}✓${RESET} $script"
        fi
    done
    
    # Add aliases
    log "Adding bash aliases..."
    cat >> "$HOME_DIR/.bashrc" << 'BASHRC'

# Ubuntu VM aliases
alias ubuntu='~/ubuntu-linux'
alias ubuntu-console='~/ubuntu-vm-console'
alias ubuntu-backup='~/ubuntu-vm-backup'
alias ubuntu-health='~/ubuntu-vm-health'
BASHRC
    
    source "$HOME_DIR/.bashrc"
    
    success_animation
    echo -e "  ${GREEN}Scripts installed!${RESET}"
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
    echo -e "${CYAN}├─────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET}  ${DIM}Commands:${RESET}                                       ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}    ${YELLOW}ubuntu${RESET}         - Quick start VM                   ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}    ${YELLOW}ubuntu-console${RESET} - Interactive menu                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}    ${YELLOW}ubuntu-backup${RESET}  - Backup VM                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}    ${YELLOW}ubuntu-health${RESET}  - Check disk health                ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${WHITE}Documentation:${RESET}"
    echo -e "  ${BLUE}https://github.com/yourusername/ubuntu-termux-vm${RESET}"
    echo ""
    echo -e "${DIM}First boot takes 2-5 minutes for auto-setup.${RESET}"
    echo -e "${DIM}Exit VM: Press Ctrl+A then X${RESET}"
    echo ""
    echo -e "${GREEN}Enjoy your Ubuntu VM! 🐧📱${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

main() {
    welcome
    setup_storage
    update_packages
    install_dependencies
    download_ubuntu
    create_disk
    create_cloud_init
    copy_scripts
    final_message
}

# Run
main
