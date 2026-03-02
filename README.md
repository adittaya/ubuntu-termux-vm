# 🐘 Ubuntu VM for Termux - Complete Android Virtualization Solution

[![GitHub stars](https://img.shields.io/github/stars/yourusername/ubuntu-termux-vm?style=for-the-badge)]()
[![GitHub forks](https://img.shields.io/github/forks/yourusername/ubuntu-termux-vm?style=for-the-badge)]()
[![GitHub issues](https://img.shields.io/github/issues/yourusername/ubuntu-termux-vm?style=for-the-badge)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)]()
[![Termux](https://img.shields.io/badge/Termux-Android-green?style=for-the-badge&logo=android)]()
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange?style=for-the-badge&logo=ubuntu)]()

> **Run full Ubuntu 24.04 LTS on your Android phone with Termux + QEMU - No root required!**

---

## 🚀 Quick Start (One Command!)

For **first-time Termux users** - just installed Termux and never opened it? **Perfect!** Follow this:

### Step 1: Install Termux

Download from **F-Droid** (recommended) or GitHub:

[![Download on F-Droid](https://fdroid.gitlab.io/artwork/badge/get-it-on.png)](https://f-droid.org/en/packages/com.termux/)

**⚠️ DO NOT download from Google Play** - it's outdated!

### Step 2: Open Termux & Run Installer

```bash
curl -L https://raw.githubusercontent.com/yourusername/ubuntu-termux-vm/main/install.sh | bash
```

**That's it!** The script will:
- ✅ Set up storage permissions
- ✅ Update & upgrade all packages
- ✅ Install QEMU + all dependencies
- ✅ Download Ubuntu 24.04 ARM64 (500MB)
- ✅ Configure cloud-init for auto-setup
- ✅ Create 25GB virtual disk
- ✅ Set up all services (SSH, VS Code, File Browser)
- ✅ Configure maximum performance settings

**Installation takes 5-10 minutes** - sit back and watch the animated progress!

### Step 3: Start Ubuntu VM

After installation completes:

```bash
ubuntu-console
```

Then press **ENTER** on "START VM" - Ubuntu boots automatically!

### Step 4: Connect

From another Termux session (swipe right → New Session):

```bash
ssh -p 2222 root@localhost
# Password: root
```

---

## 📋 What You Get

| Feature | Description |
|---------|-------------|
| 🐧 **Ubuntu 24.04 LTS** | Full desktop-class Linux |
| 🔐 **SSH Access** | Connect from Termux |
| 💻 **VS Code Web** | Code at http://localhost:8080 |
| 📁 **File Browser** | Manage files at http://localhost:9000 |
| 🌐 **Web Terminal** | Browser terminal at http://localhost:7681 |
| 📊 **Console UI** | Game-like settings menu |
| 📥 **Auto-Download** | Missing files download automatically |
| 🔧 **Troubleshooting** | Built-in diagnostics |
| 💾 **Backup System** | One-click VM backups |
| ⚡ **Max Performance** | Optimized for Android |

---

## 🎮 Console Features

```bash
ubuntu-console
```

**Interactive TUI Menu:**
- ⚙️ Adjust CPU cores (1-8)
- 💾 Change RAM (1G-8G)
- 💿 Select cache mode
- 📊 Real-time performance score
- 🛡️ Data safety indicators
- 📥 Download missing files
- 🔧 Troubleshoot issues
- 💾 Backup/Restore

---

## 📦 Package Requirements

All automatically installed by the installer, but here's what you need:

| Package | Purpose | Size |
|---------|---------|------|
| `qemu-system-aarch64` | ARM64 virtualization | ~50MB |
| `xorriso` | ISO creation | ~1MB |
| `wget` / `curl` | Downloads | ~1MB |
| `openssh` | SSH server | ~2MB |
| `git` | Version control | ~10MB |

**Total:** ~64MB (Ubuntu cloud image ~500MB downloaded separately)

---

## 🛠️ Manual Installation

If you prefer manual setup:

```bash
# 1. Update Termux
pkg update && pkg upgrade -y

# 2. Install dependencies
pkg install qemu-system-aarch64 xorriso wget curl git -y

# 3. Setup storage
termux-setup-storage

# 4. Clone this repo
git clone https://github.com/yourusername/ubuntu-termux-vm.git
cd ubuntu-termux-vm

# 5. Run setup
./setup-ubuntu-vm.sh

# 6. Start VM
ubuntu-console
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [UBUNTU-VM-COMPLETE-GUIDE.md](UBUNTU-VM-COMPLETE-GUIDE.md) | Full VM guide |
| [UBUNTU-CONSOLE-GUIDE.md](UBUNTU-CONSOLE-GUIDE.md) | Console menu guide |
| [INSTALL.md](INSTALL.md) | Detailed installation |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Fix common issues |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |

---

## 🎯 First-Time User Guide

### You just installed Termux? Here's everything:

**1. What is Termux?**
- Terminal emulator for Android
- Gives you Linux command line
- No root needed
- Completely free & open source

**2. What is this project?**
- Runs Ubuntu Linux inside Termux
- Uses QEMU virtualization
- Your phone becomes a Linux computer
- Access via SSH or web browser

**3. Do I need coding knowledge?**
- **NO!** The installer is fully automatic
- Just copy-paste one command
- Everything happens automatically

**4. Will it damage my phone?**
- **NO!** Completely safe
- Runs in a sandboxed environment
- Doesn't modify system files
- Can be uninstalled anytime

**5. How much storage needed?**
- Installer: ~100MB
- Ubuntu image: ~500MB
- Virtual disk: ~200MB (grows to 25GB)
- **Total: ~1GB recommended**

**6. Does it drain battery?**
- Similar to running any app
- VM uses more when active
- Pause/stop when not using

---

## 🔧 Troubleshooting

### Common Issues

**"Permission denied" errors:**
```bash
termux-setup-storage
```

**"Package not found":**
```bash
termux-change-repo
# Select main repo
pkg update -f
```

**Download fails:**
```bash
# Run troubleshooting
ubuntu-console
# Select [6] Troubleshooting
```

**VM won't start:**
```bash
# Check requirements
ubuntu-vm-health

# Re-download files
ubuntu-console → Download Missing Files
```

**Need help?**
- 📖 Read [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- 💬 Open an [Issue](https://github.com/yourusername/ubuntu-termux-vm/issues)
- 💡 Check [FAQ](#faq)

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to submit PRs
- Code style guidelines
- Testing requirements
- Documentation standards

**Ways to help:**
- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve docs
- 🔧 Fix issues
- 🌍 Translate

---

## 📊 Performance

| Device Tier | CPU Cores | RAM | Performance Score |
|-------------|-----------|-----|-------------------|
| Flagship | 8 | 8G+ | 95-100 (MAX) |
| Mid-range | 6 | 6G | 80-90 (HIGH) |
| Budget | 4 | 4G | 60-75 (MEDIUM) |
| Entry | 4 | 2-3G | 40-55 (LOW) |

---

## 🔒 Security

| Feature | Status |
|---------|--------|
| Root access | Not required |
| Network isolation | Yes (NAT) |
| File sharing | Optional (VirtFS) |
| SSH password | Change after first login |
| Data encryption | QCOW2 format |

**Recommendations:**
1. Change default password: `passwd`
2. Setup SSH keys
3. Don't expose ports publicly
4. Regular backups

---

## 📱 Compatible Devices

**Tested & Working:**
- Samsung Galaxy S series (S20+)
- Google Pixel (4+)
- OnePlus (8+)
- Xiaomi (Mi 10+)
- Huawei (P40+)

**Requirements:**
- Android 10+
- ARM64 processor
- 4GB+ RAM (8GB recommended)
- 2GB+ free storage

---

## 🎓 Learning Resources

New to Linux? Check these:
- [Linux Command Line Basics](https://linuxjourney.com/)
- [Ubuntu Documentation](https://help.ubuntu.com/)
- [Termux Wiki](https://wiki.termux.com/)
- [QEMU Documentation](https://www.qemu.org/docs/)

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file

---

## 🙏 Acknowledgments

- [Termux](https://termux.org/) - Android terminal
- [QEMU](https://www.qemu.org/) - Virtualization
- [Ubuntu](https://ubuntu.com/) - Linux distribution
- [cloud-init](https://cloud-init.io/) - Auto-configuration

---

## 📞 Support

| Platform | Link |
|----------|------|
| GitHub Issues | [Report Bug](https://github.com/yourusername/ubuntu-termux-vm/issues) |
| Discussions | [Ask Question](https://github.com/yourusername/ubuntu-termux-vm/discussions) |
| Documentation | [Read Docs](https://github.com/yourusername/ubuntu-termux-vm/wiki) |

---

<div align="center">

**Made with ❤️ for the Android community**

[⬆ Back to Top](#ubuntu-vm-for-termux---complete-android-virtualization-solution)

</div>
