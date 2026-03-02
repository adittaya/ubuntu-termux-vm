# 🐉 Kali Linux (Pure CLI) VM for Termux

[![GitHub stars](https://img.shields.io/github/stars/adittaya/ubuntu-termux-vm?style=for-the-badge)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)]()
[![Termux](https://img.shields.io/badge/Termux-Android-green?style=for-the-badge&logo=android)]()
[![Debian](https://img.shields.io/badge/Debian-12-red?style=for-the-badge&logo=debian)]()

> **Run Kali Linux (Pure CLI) on your Android phone with Termux + QEMU - No root required!**

---

## 🚀 Quick Start (One Command!)

```bash
curl -L https://raw.githubusercontent.com/adittaya/ubuntu-termux-vm/main/install-kali.sh | bash
```

**That's it!** The script will:
- ✅ Set up storage permissions
- ✅ Install QEMU + dependencies
- ✅ Download Debian 12 ARM64 (Kali base - 415MB)
- ✅ Configure cloud-init for auto-setup
- ✅ Create 20GB virtual disk
- ✅ Set up SSH access

**Installation takes 5-10 minutes** - sit back and watch!

### Start Kali

```bash
kali
```

### Connect via SSH

From another Termux session:

```bash
ssh -p 2222 root@localhost
# Password: root
```

---

## 📋 What You Get

| Feature | Description |
|---------|-------------|
| 🐧 **Debian 12** | Kali Linux base (Pure CLI) |
| 🔐 **SSH Access** | Connect from Termux |
| 📊 **Console UI** | Smart boot detection |
| 📥 **Auto-Setup** | Cloud-init configuration |
| 💾 **Backup System** | QCOW2 disk format |
| ⚡ **Max Performance** | Optimized for Android |

**NO Kali tools installed** - Pure CLI base only!

---

## 🎯 Commands

```bash
kali           # Start Kali VM
~/kali-linux   # Also works (full path)
```

**Inside VM:**
```bash
dev-on         # Check services
ssh-start      # Start SSH
sysinfo        # System information
```

---

## 📦 Requirements

| Requirement | Details |
|-------------|---------|
| **Termux** | From F-Droid or GitHub |
| **QEMU** | Installed automatically |
| **Storage** | 2GB+ free space |
| **Android** | 10+ recommended |
| **RAM** | 4GB+ recommended |

---

## 🛠️ Manual Installation

```bash
# 1. Update Termux
pkg update && pkg upgrade -y

# 2. Install dependencies
pkg install qemu-system-aarch64 xorriso wget curl git -y

# 3. Setup storage
termux-setup-storage

# 4. Clone repo
git clone https://github.com/adittaya/ubuntu-termux-vm.git
cd ubuntu-termux-vm

# 5. Run setup (coming soon)
./setup-kali-vm.sh

# 6. Start Kali
kali
```

---

## 🔧 Troubleshooting

### "command not found"

```bash
~/kali-linux
```

### VM won't start

```bash
# Check files
ls -la ~/storage/shared/kali-vm/

# Check disk
qemu-img check ~/storage/shared/kali-vm/kali-disk.qcow2
```

### SSH connection refused

Wait 2-5 minutes for first boot setup, then retry.

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [INSTALL.md](INSTALL.md) | Detailed installation |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Fix common issues |

---

## 🎓 About Kali Linux (Pure CLI)

This is **NOT** full Kali Linux with tools. This is:

- **Debian 12** (Kali's base)
- **Pure CLI** (no GUI)
- **No Kali tools** (install what you need)
- **Lightweight** (~415MB base)

**Install Kali tools manually:**
```bash
# Inside VM
apt update
apt install kali-linux-core  # Base Kali tools
# OR install specific tools
apt install nmap metasploit-framework sqlmap
```

---

## 🔒 Security

| Setting | Value |
|---------|-------|
| **Root Login** | Enabled (dev only) |
| **Password** | root (change it!) |
| **SSH Port** | 2222 |

**Change password after first login:**
```bash
passwd
```

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file

---

## 🙏 Acknowledgments

- [Termux](https://termux.org/) - Android terminal
- [QEMU](https://www.qemu.org/) - Virtualization
- [Debian](https://debian.org/) - Linux distribution
- [Kali Linux](https://kali.org/) - Security distribution

---

## 📞 Support

| Platform | Link |
|----------|------|
| GitHub Issues | [Report Bug](https://github.com/adittaya/ubuntu-termux-vm/issues) |
| Discussions | [Ask Question](https://github.com/adittaya/ubuntu-termux-vm/discussions) |

---

<div align="center">

**Made with ❤️ for the Android security community**

[⬆ Back to Top](#-kali-linux-pure-cli-vm-for-termux)

</div>
