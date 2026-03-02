# Troubleshooting Guide

## Common Issues & Solutions

### Installation Issues

#### "Permission denied" when running installer

**Solution:**
```bash
termux-setup-storage
# Allow permission when prompted
```

#### "Package not found"

**Solution:**
```bash
termux-change-repo
# Select 'Main' repository
pkg update -f
```

#### Download fails repeatedly

**Solution 1 - Check network:**
```bash
ping -c 3 cloud-images.ubuntu.com
```

**Solution 2 - Manual download:**
```bash
wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img \
    -O ~/storage/shared/ubuntu-vm/ubuntu-cloud.img
```

**Solution 3 - Use alternative mirror:**
```bash
wget https://mirrors.edge.kernel.org/ubuntu-cloud/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img \
    -O ~/storage/shared/ubuntu-vm/ubuntu-cloud.img
```

### VM Issues

#### VM won't start

**Check requirements:**
```bash
ubuntu-vm-health
```

**Check UEFI:**
```bash
ls -la $PREFIX/share/qemu/edk2-aarch64-code.fd
```

**Reinstall QEMU:**
```bash
pkg install qemu-system-aarch64 --reinstall
```

#### SSH connection refused

**Wait for first boot** (2-5 minutes for setup)

**Check if SSH is running:**
```bash
# Inside VM console
dev-on
```

**Restart SSH:**
```bash
# Inside VM
service ssh restart
```

**Clear host keys:**
```bash
ssh-keygen -R '[localhost]:2222'
```

#### Slow performance

**Reduce VM resources:**
```bash
ubuntu-console
# Set CPU: 2-4 cores
# Set RAM: 2-3G
# Set Cache: writeback
```

**Close other apps**

**Check storage space:**
```bash
df -h
```

### Download Issues

#### All mirrors failed

**Manual installation:**
```bash
cd ~/storage/shared/ubuntu-vm

# Download Ubuntu
wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img

# Verify size (should be ~500MB)
ls -lh ubuntu-cloud.img

# Run console
ubuntu-console
```

#### wget/curl not working

**Install alternatives:**
```bash
pkg install wget curl -y
```

### Storage Issues

#### "No space left on device"

**Check free space:**
```bash
df -h
```

**Clean up:**
```bash
# Clear apt cache
apt clean

# Remove old backups
rm ~/storage/shared/ubuntu-vm/backups/*.qcow2.old

# Check large files
du -sh ~/storage/shared/*
```

#### Permission denied on files

**Fix permissions:**
```bash
chmod -R 755 ~/storage/shared/ubuntu-vm/
```

### Network Issues

#### Can't connect to web services

**Check port forwarding:**
```bash
# In Termux
netstat -tlnp | grep 2222
netstat -tlnp | grep 8080
```

**Restart VM**

**Check firewall:**
```bash
# Inside VM
ufw status
```

### First Boot Issues

#### Cloud-init not running

**Check cloud-init ISO:**
```bash
ls -la ~/storage/shared/ubuntu-vm/cloud-init.iso
```

**Regenerate:**
```bash
cd ~/storage/shared/ubuntu-vm/cloud-init
xorriso -as mkisofs -volid CIDATA -joliet -rock -output ../cloud-init.iso .
```

#### Services not starting

**Manual start:**
```bash
# Inside VM
ssh-start
```

**Check logs:**
```bash
tail -f /var/log/syslog
```

### Backup/Restore Issues

#### Backup fails

**Check space:**
```bash
df -h ~/storage/shared/ubuntu-vm/backups/
```

**Manual backup:**
```bash
cp ~/storage/shared/ubuntu-vm/ubuntu-disk.qcow2 \
   ~/storage/shared/ubuntu-vm/ubuntu-disk.backup.qcow2
```

#### Restore fails

**VM must be stopped first**

**Check backup integrity:**
```bash
qemu-img check ~/storage/shared/ubuntu-vm/backups/*.qcow2
```

### Getting Help

#### Collect debug info

```bash
# System info
uname -a
cat /proc/cpuinfo | head -5
free -h

# Termux version
pkg list-installed | grep termux

# QEMU version
qemu-system-aarch64 --version

# Logs
cat ~/storage/shared/ubuntu-vm/console.log
```

#### Report a bug

Include:
1. Device model
2. Android version
3. Termux version
4. Error messages
5. Steps to reproduce
6. Debug info above

**Open issue:** https://github.com/yourusername/ubuntu-termux-vm/issues

---

## Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Permission denied | `termux-setup-storage` |
| Package not found | `termux-change-repo` |
| Download fails | Try alternative mirror |
| SSH refused | Wait 2-5 min, then retry |
| Slow performance | Reduce CPU/RAM in console |
| No space | `apt clean` + remove old backups |
| VM won't start | `ubuntu-vm-health` |

---

## Still Having Issues?

1. **Check documentation:**
   - [README.md](README.md)
   - [INSTALL.md](INSTALL.md)
   - [CONTRIBUTING.md](CONTRIBUTING.md)

2. **Search existing issues:**
   - https://github.com/yourusername/ubuntu-termux-vm/issues

3. **Open new issue:**
   - Include all debug info
   - Describe problem clearly
   - Add screenshots if helpful

4. **Community help:**
   - GitHub Discussions
   - Termux Reddit: r/termux
   - Termux Wiki: wiki.termux.com
