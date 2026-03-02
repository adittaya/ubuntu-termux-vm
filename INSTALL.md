# Installation Guide

## For First-Time Termux Users

### Step 1: Install Termux

**Download from F-Droid (Recommended):**

[![Get it on F-Droid](https://fdroid.gitlab.io/artwork/badge/get-it-on.png)](https://f-droid.org/en/packages/com.termux/)

**Or from GitHub:**

[![Download from GitHub](https://img.shields.io/github/downloads/termux/termux-app/latest/total?style=for-the-badge)](https://github.com/termux/termux-app/releases)

**⚠️ DO NOT use Google Play Store version** - it's outdated and unsupported!

### Step 2: Initial Setup

1. **Open Termux** (first time opening)
2. **Wait** for initial setup to complete
3. You'll see a command prompt like: `~ $`

### Step 3: Run Installer

Copy and paste this command:

```bash
curl -L https://raw.githubusercontent.com/yourusername/ubuntu-termux-vm/main/install.sh | bash
```

**How to paste in Termux:**
- **Volume Up + V** or
- **Long press** on screen → Paste

### Step 4: Allow Permissions

When prompted:
1. Tap **"Allow"** on storage permission popup
2. If no popup appears, type: `termux-setup-storage`
3. Press **ENTER** in Termux

### Step 5: Wait for Installation

The installer will:
- Show animated progress
- Download packages (~64MB)
- Download Ubuntu (~500MB)
- Create virtual disk
- Configure everything

**Takes 5-10 minutes** depending on internet speed.

### Step 6: Start Ubuntu

After installation:

```bash
ubuntu-console
```

Press **ENTER** on "START VM"

### Step 7: Connect

**Swipe right** → **New Session** → Run:

```bash
ssh -p 2222 root@localhost
# Password: root
```

**Done!** You're now running Ubuntu on your phone! 🎉

---

## Manual Installation

For advanced users who prefer manual setup:

### Prerequisites

```bash
# Update Termux
pkg update && pkg upgrade -y

# Install dependencies
pkg install qemu-system-aarch64 xorriso wget curl git -y

# Setup storage
termux-setup-storage
```

### Clone Repository

```bash
git clone https://github.com/yourusername/ubuntu-termux-vm.git
cd ubuntu-termux-vm
```

### Run Setup

```bash
./setup-ubuntu-vm.sh
```

### Start VM

```bash
ubuntu-console
```

---

## Post-Installation

### Change Password (Recommended)

```bash
# Inside Ubuntu VM
passwd
```

### Update Ubuntu

```bash
# Inside Ubuntu VM
apt update && apt upgrade -y
```

### Install Additional Software

```bash
# Inside Ubuntu VM
apt install python3 nodejs npm vim htop -y
```

---

## Verification

### Check Installation

```bash
# Check all files exist
ubuntu-vm-health

# Expected output:
# ✓ Disk integrity: OK
# ✓ All files found
```

### Test Services

```bash
# Inside VM
dev-on

# Expected:
# [OK] SSH
# [OK] VS Code
# [OK] File Browser
# [OK] Web Terminal
```

---

## System Requirements

### Minimum

- Android 10+
- ARM64 processor
- 4GB RAM
- 2GB free storage

### Recommended

- Android 12+
- Octa-core processor
- 8GB RAM
- 5GB free storage

---

## Uninstallation

### Remove Ubuntu VM

```bash
# Stop VM if running
# Press Ctrl+A then X

# Remove files
rm -rf ~/storage/shared/ubuntu-vm
rm -rf ~/ubuntu_share

# Remove scripts
rm ~/ubuntu-linux ~/ubuntu-console ~/ubuntu-vm-backup ~/ubuntu-vm-health

# Remove aliases from .bashrc
nano ~/.bashrc
# Delete Ubuntu VM aliases section
```

### Remove Termux

1. Long-press Termux icon
2. Tap "Uninstall"

---

## Next Steps

- [Read Console Guide](UBUNTU-CONSOLE-GUIDE.md)
- [Learn Ubuntu Basics](https://linuxjourney.com/)
- [Explore Termux](https://wiki.termux.com/)

---

## Getting Help

| Issue | Solution |
|-------|----------|
| Installation fails | See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| VM won't start | Run `ubuntu-vm-health` |
| Can't connect | Check SSH section in README |
| Slow performance | Reduce resources in console |

**Still stuck?** Open an [issue](https://github.com/yourusername/ubuntu-termux-vm/issues)
