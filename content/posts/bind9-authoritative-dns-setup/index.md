+++
date = '2025-07-27T21:11:29-04:00'
draft = true
title = 'Bind9 Authoritative Dns Setup'
tags = ['bind9','ubuntu']
layout = 'post'
catagories = ['dns']
summmary = 'This tutorial will guide you through the complete installation and configuration of a BIND9 authoritative DNS server on an Ubuntu 24.04 VM.'
+++

# 🧭 BIND9 Authoritative DNS Server Setup for `example.local`

This guide walks through the full setup of a **BIND9 authoritative DNS server** on Ubuntu 24.04. It will:

- Serve authoritative DNS for `example.local`
- Forward all other queries securely using **DNS-over-HTTPS (DoH)**

---

## 🌐 Environment Overview

- **DNS Server**: `bind9.example.local` at `192.168.1.10`
- **Domain**: `example.local`
- **DoH Forwarders**: Quad9, Mullvad, Google, Cloudflare
- **LAN**: `192.168.1.0/24`

> 💡 Commands use `sudo` for best practice, but you may omit it if running as root.

---

## 🚀 Step 1: System Update and BIND9 Installation

```bash
sudo apt update
sudo apt install bind9 bind9utils -y
sudo systemctl status bind9
```

---

## ⚙️ Step 2: Configure BIND9 Options

Edit:

```bash
sudo nano /etc/bind/named.conf.options
```

Replace with:

```conf
acl "trusted" {
    192.168.1.0/24;
    localhost;
    localnets;
};

options {
    directory "/var/cache/bind";
    forwarders {
        127.0.0.1 port 5053;
    };
    forward only;
    recursion yes;
    allow-query { trusted; };
    allow-transfer { none; };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
```

---

## 🗂 Step 3: Define Local Zones

Edit:

```bash
sudo nano /etc/bind/named.conf.local
```

Add:

```conf
zone "example.local" IN {
    type master;
    file "/etc/bind/db.example.local";
    allow-update { none; };
};

zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/db.192.168.1";
    allow-update { none; };
};
```

---

## 📁 Step 4: Create Forward Zone File

Create the zone file:

```bash
sudo nano /etc/bind/db.example.local
```

Include `A` and `CNAME` records.

---

## 🔁 Step 5: Create Reverse Zone File

Create the reverse zone file:

```bash
sudo nano /etc/bind/db.192.168.1
```

Include `PTR` records for reverse DNS.

---

## 🔒 Step 6: Configure DNS-over-HTTPS (DoH)

### A. Install `cloudflared`

```bash
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt update
sudo apt install cloudflared -y
```

### B. Configure `cloudflared`

Create config file:

```bash
sudo nano /etc/cloudflared/config.yml
```

Paste:

```yaml
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-address: 127.0.0.1
proxy-dns-upstream:
  - https://dns.quad9.net/dns-query
  - https://base.dns.mullvad.net/dns-query
  - https://dns.google/dns-query
  - https://security.cloudflare-dns.com/dns-query
```

Create user and service:

```bash
sudo useradd -s /usr/sbin/nologin -r -M cloudflared
sudo chown cloudflared:cloudflared /etc/cloudflared/config.yml
sudo nano /etc/systemd/system/cloudflared.service
```

Paste into service file:

```ini
[Unit]
Description=Cloudflare DNS over HTTPS proxy
After=network-online.target
Wants=network-online.target

[Service]
User=cloudflared
Group=cloudflared
Type=simple
ExecStart=/usr/bin/cloudflared --config /etc/cloudflared/config.yml --no-autoupdate
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

---

## ✅ Step 7: Validate & Restart BIND9

```bash
sudo named-checkconf
sudo named-checkzone example.local /etc/bind/db.example.local
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/db.192.168.1
sudo systemctl restart bind9
```

---

## 🧪 Step 8: Test Your DNS Server

```bash
dig @127.0.0.1 test.example.local
dig @127.0.0.1 www.google.com
```

---

## 🛠 Step 9: Final Integration with Your Router (e.g., pfSense)

### DHCP Settings

- Set **DNS Server** to: `192.168.1.10`

### DNS Resolver (Optional)

- Add **Domain Override**:
  - **Domain**: `example.local`
  - **IP**: `192.168.1.10`
  - **Description**: Authoritative BIND9 Server

---

🎉 Your BIND9 server is now fully configured for secure and authoritative DNS over your network!
