+++
title = 'SSH Management Utilities'
date = '2025-07-26'
draft = false
tags = ["ssh", "security", "linux", "windows", "utilities"]
summary = "Guides and scripts for securing and managing SSH configurations, keys, and connections."
layout = 'post'
+++

A collection of guides and scripts for securing and managing SSH configurations, keys, and connections.

---

## 🔐 1. Secure Root Login with Key-Only Authentication

**Purpose:**  
Enhances server security by disabling password-based authentication for the `root` user. Modifies the SSH daemon configuration (`sshd_config`) to permit root login only via public key authentication. This protects your server from brute-force password attacks.

> ⚠️ **Important Prerequisite:**  
> You **MUST** have SSH key-based authentication configured and tested for root access before applying this script.

### Installation and Usage

```bash
nano ssh_key_only.sh     # Create the script
chmod +x ssh_key_only.sh # Make it executable
sudo ./ssh_key_only.sh   # Run as root
```

### Script

```bash
#!/bin/bash
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_DIR="/etc/ssh/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/sshd_config_backup_$TIMESTAMP"

error_exit() {
     echo "Error: $1" >&2
     exit 1
}

if [[ $EUID -ne 0 ]]; then
    error_exit "This script must be run as root."
fi

echo "Creating a backup..."
mkdir -p "$BACKUP_DIR" || error_exit "Could not create backup directory."
cp "$SSHD_CONFIG" "$BACKUP_FILE" || error_exit "Could not create backup file."
echo "Backup created at $BACKUP_FILE"

echo "Updating sshd_config..."
if grep -qE "^\s*#?\s*PermitRootLogin" "$SSHD_CONFIG"; then
     sed -i.bak -E "s/^\s*#?\s*PermitRootLogin.*/PermitRootLogin prohibit-password/" "$SSHD_CONFIG"
else
     echo "PermitRootLogin prohibit-password" >> "$SSHD_CONFIG"
fi

if grep -q "PermitRootLogin prohibit-password" "$SSHD_CONFIG"; then
     echo "PermitRootLogin updated."
else
     error_exit "Failed to update setting. Restoring from backup."
     cp "$BACKUP_FILE" "$SSHD_CONFIG"
fi

echo "Restarting SSH service..."
if [ -d /run/systemd/system ]; then
     systemctl restart sshd || error_exit "Failed to restart sshd via systemctl."
else
     service ssh restart || /etc/init.d/sshd restart || error_exit "Failed to restart sshd."
fi

echo "✔️ SSH configured successfully. Root login now requires keys only."
```

---

## 👤 2. Copying an SSH Key from Root to a New User

### ✅ Scenario 1: New User Has `sudo` Access

```bash
mkdir -p /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
sudo cp /root/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
sudo chown -R $USER:$USER /home/$USER/.ssh
sudo chmod 600 /home/$USER/.ssh/authorized_keys
```

### 🛑 Scenario 2: New User Has NO `sudo` Access

```bash
NEW_USER="<your_username>"

mkdir -p /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
```

---

## 🧱 3. Create a Secure, Key-Only Sudo User

> Run all commands as the **root** user.

### 1. Create User and Grant Sudo Access

```bash
adduser <newuser>
usermod -aG sudo <newuser>  # Debian/Ubuntu systems
```

### 2. Set Up SSH Key Auth from Root

```bash
NEWUSER="<newuser>"
mkdir -p /home/$NEWUSER/.ssh
cp /root/.ssh/authorized_keys /home/$NEWUSER/.ssh/authorized_keys
chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh
chmod 700 /home/$NEWUSER/.ssh
chmod 600 /home/$NEWUSER/.ssh/authorized_keys
```

### 3. Enable Passwordless `sudo`

```bash
echo "$NEWUSER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/01-$NEWUSER-nopasswd
chmod 440 /etc/sudoers.d/01-$NEWUSER-nopasswd
```

### 4. Harden SSH Configuration

Edit `/etc/ssh/sshd_config`:

```bash
PermitRootLogin no
PasswordAuthentication no
```

Ensure:

```bash
PubkeyAuthentication yes
```

Restart the SSH daemon:

```bash
systemctl restart sshd
```

Test with:

```bash
ssh <newuser>@your_server_ip
sudo whoami
```

---

## 💻 4. Transferring an SSH Key from Windows 11 to Ubuntu

### Requirements

- Windows 11 with OpenSSH installed
- Key pair generated using `ssh-keygen`

### Steps

```powershell
# From Windows PowerShell
scp C:\Users\<YourWindowsUser>\.ssh\id_rsa.pub <ubuntu_user>@<server_ip>:~/
```

```bash
# Then log into Ubuntu and run:
ssh <ubuntu_user>@<server_ip>
mkdir -p ~/.ssh
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
rm ~/id_rsa.pub
```

---

## 🧹 5. Utility to Clean `known_hosts` File

Use this script to remove malformed lines from `~/.ssh/known_hosts`.

### Script

```bash
#!/bin/bash
KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
BACKUP_FILE="$KNOWN_HOSTS_FILE.bak"

echo "[*] Backing up known_hosts to $BACKUP_FILE"
cp "$KNOWN_HOSTS_FILE" "$BACKUP_FILE"

echo "[*] Removing malformed lines..."
awk 'NF >= 3' "$BACKUP_FILE" > "$KNOWN_HOSTS_FILE"

echo "[+] Cleaned known_hosts written."
echo "[!] Original backed up as $BACKUP_FILE"
```

---

For maximum security and reliability, remember to test each change before closing your root session, especially after altering SSH configurations.
