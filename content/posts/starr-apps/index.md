---
title: "Starr Apps Stack - Complete Media Server Suite"
date: 2025-08-07T22:00:00-04:00
draft: false
description: "A comprehensive media server stack featuring Jellyfin, the *arr suite, and supporting applications for a complete home media solution."
categories: ["Docker", "Self-Hosted"]
tags: ["media-server", "jellyfin", "docker-compose", "homelab", "self-hosted", "media-management"]
author: "russmorefield"
showToc: true
TocOpen: false
hidemeta: false
comments: true
canonicalURL: "https://github.com/russmorefield/docker-compose-stacks/tree/main/starr-apps"
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "featured.png" # Replace with your image URL
    alt: "Starr Apps Stack Banner"
    caption: "Complete Media Server Stack"
    relative: false
    hidden: false
---

A fully integrated media server solution designed for homelab enthusiasts and self-hosters. This stack combines Jellyfin for media streaming, the complete *arr suite for automated media management, and essential supporting applications for downloading, organizing, and serving movies, TV shows, music, and photos. With built-in support for Intel Arc A310 hardware-accelerated transcoding, secure VPN routing for torrent traffic, and automated container updates, the Starr Apps Stack delivers a robust, scalable, and easy-to-maintain platform for managing your entire home media library. Whether you're building a new server or upgrading an existing setup, this guide provides step-by-step instructions for installation, configuration, and optimization on modern Linux systems.

## 🚀 Prerequisites

1. Ubuntu Server 24.04 LTS (Headless)
2. Intel Arc A310 ECO
3. Docker and Docker Compose installed
4. Create the required network:

   ```bash
   docker network create starr-apps
   ```

5. Required directory structure:

   ```plaintext
   /home/$USER/docker/appdata/
   /home/$USER/data/
   ```

## 📋 Services

- **Jellyfin**: Media server for movies, TV shows, music, and photos
- **Jellyseerr**: Request management system for Jellyfin
- **Prowlarr**: Indexer manager/proxy for *arr apps
- **Whisparr**: Adult movie collection manager
- **Stash**: Media organization and tagging
- **Lidarr**: Music collection manager
- **Radarr**: Movie collection manager
- **Sonarr**: TV series collection manager
- **Bazarr**: Subtitle management
- **SABnzbd**: Usenet downloader
- **qBittorrent**: (via Gluetun) Torrent client
- **Gluetun**: VPN client container
- **Watchtower**: Automatic container updates


## Intel Arc A310 ECO Setup for Jellyfin Hardware Transcoding (Ubuntu 24.04 LTS)

This guide provides a step-by-step procedure for installing, configuring, and verifying your new Intel Arc A310 ECO graphics card for hardware-accelerated transcoding in Jellyfin on a headless Ubuntu 24.04.2 LTS server. This guide is focused on a Docker-based installation. Following these steps methodically will ensure optimal performance, stability, and power efficiency.

## Section 1: Pre-Installation: Critical BIOS/UEFI Configuration

Before installing the GPU, it is essential to configure your server's motherboard BIOS/UEFI. These settings are mandatory for the Arc A310 to perform correctly and operate at its lowest idle power state, a crucial factor for a 24/7 server.

To enter your BIOS/UEFI setup, restart your server and press the appropriate key during boot (commonly `Del`, `F2`, or `F12`).


1. **Enable Resizable BAR (ReBAR):** This feature allows the CPU to access the GPU's entire video memory at once, improving performance. While its impact on transcoding is less dramatic than in gaming, it is still recommended for stability and optimal performance, particularly with tone-mapping.

  - Navigate to a menu such as "PCI Subsystem Settings" or "Advanced."
  - Locate the option for **"Re-Size BAR Support"** and set it to `Enabled` or `Auto`.

2. **Enable Active State Power Management (ASPM):** This is the most critical step for achieving low power consumption when the GPU is idle. Without these settings, the Arc A310 can draw a significant amount of power (~40W) even when doing nothing. Correct configuration can reduce this to a much more server-appropriate level (~10W).

  - Find the "PCI Express" or "Power Management" settings.
  - Set **`Native ASPM`** to `Enabled`. This allows the operating system to manage PCIe power states.
  - Enable **`PCI Express Root Port ASPM`**.
  - Within the ASPM options, ensure **`L1 Substates`** is selected or enabled. This specific sub-state allows the PCIe link to enter its deepest low-power mode.

After configuring these settings, save your changes and shut down the server to physically install the Intel Arc A310 ECO.

## Section 2: Driver and Software Installation on Ubuntu 24.04 LTS

Ubuntu 24.04 LTS includes a modern kernel (6.8 or newer) that supports the Intel Arc architecture out of the box, simplifying the setup process significantly compared to older operating systems.


1. Update System Packages:

  Ensure your server's package list and all installed software are fully up to date.

  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

After installing the software, it is crucial to verify that the driver is loaded correctly and that the GPU's low-level firmware is operational.


1. Verify Microcontroller Firmware (GuC/HuC):

   The Graphics (GuC) and HEVC/H.265 (HuC) microcontrollers are essential for the GPU's hardware encoding and power management features to function correctly.

   - **Check GuC Status:**

     ```bash
     sudo cat /sys/kernel/debug/dri/0/gt/uc/guc_info
     ```

     The output should contain the line `status: RUNNING`.

   - **Check HuC Status:**

     ```bash
     sudo cat /sys/kernel/debug/dri/0/gt/uc/huc_info
     ```

     The output should also contain the line `status: RUNNING`.

   - **Troubleshooting:** If either firmware is not running, it may indicate an issue with the `linux-firmware` package. On a standard Ubuntu 24.04 installation, this should not be an issue. If it is, ensure the `dg2_*.bin` files are present in `/lib/firmware/i915/`.

2. Verify VA-API Driver and Codec Support:

   Use the vainfo utility to confirm that the VA-API driver is loaded and to see a list of supported codecs. This is a direct confirmation that Jellyfin will be able to see and use the GPU.

   ```bash
   vainfo --display drm --device /dev/dri/renderD128
   ```

   The output should be a long list of supported entrypoints, including `VAProfileHEVCMain10` (for 10-bit HEVC), `VAProfileVP9Profile2` (for VP9), and `VAProfileAV1Profile0` (for AV1), confirming the GPU's full capabilities are available to the system.

## 📦 Installation

1. Clone this repository
2. Configure VPN settings:
   - Create a `.env` file with your Wireguard configuration:

     ```env
     WG_PRIVATE_KEY=your_private_key
     WG_ADDRESSES=your_addresses
     WG_PUBLIC_KEY=your_public_key
     WG_ENDPOINT_IP=your_endpoint_ip
     WG_ENDPOINT_PORT=your_endpoint_port
     WG_PRESHARED_KEY=your_preshared_key  # Optional
     ```

3. Start the stack:

   ```bash
   docker compose up -d
   ```

## 📄 Docker Compose Configuration

Below is the complete docker-compose.yml configuration with generic paths:

```yaml
services:
  # Ensure you have the starr-apps network created before running this stack
  # docker network create starr-apps
  jellyfin:
    container_name: jellyfin
    image: ghcr.io/hotio/jellyfin:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 8096:8096
      - 8920:8920
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/jellyfin/config:/config
      - /home/$USER/data/media:/data/media
      - /home/$USER/docker/appdata/jellyfin/transcode:/transcode
      - /home/$USER/docker/appdata/jellyfin/cache:/data/cache
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128 # Passes the GPU to the container
    group_add:
      - "122" # IMPORTANT: Change to your 'render' group GID
  jellyseerr:
    container_name: jellyseerr
    image: ghcr.io/hotio/jellyseerr
    restart: unless-stopped
    depends_on:
      - jellyfin
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - "5055:5055"
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK=002
      - TZ=your_timezone
    volumes:
      - /home/$USER/docker/appdata/jellyseerr/config:/config
      - /home/$USER/data/media:/data/media
      - /etc/localtime:/etc/localtime:ro
  prowlarr:
    container_name: prowlarr
    image: ghcr.io/hotio/prowlarr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 9696:9696
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/prowlarr/config:/config
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/prowlarr/logs:/logs
      - /home/$USER/docker/appdata/prowlarr/cache:/cache
  whisparr:
    container_name: whisparr
    image: ghcr.io/hotio/whisparr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 6969:6969
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK=002
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/whisparr/config:/config
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/whisparr/logs:/logs
      - /home/$USER/docker/appdata/whisparr/cache:/cache
  stash:
    image: stashapp/stash:latest
    container_name: stash
    restart: unless-stopped
    ports:
      - "9999:9999"
    logging:
      driver: "json-file"
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    labels:
      - com.centurylinklabs.watchtower.enable=true
    environment:
      - STASH_STASH=/data/
      - STASH_GENERATED=/generated/
      - STASH_METADATA=/metadata/
      - STASH_CACHE=/cache/
      - STASH_PORT=9999
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/stash/config:/root/.stash
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/stash/metadata:/metadata
      - /home/$USER/docker/appdata/stash/cache:/cache
      - /home/$USER/docker/appdata/stash/blobs:/blobs
      - /home/$USER/docker/appdata/stash/generated:/generated
  lidarr:
    container_name: lidarr
    image: ghcr.io/hotio/lidarr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 8686:8686
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/lidarr/config:/config
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/lidarr/logs:/logs
      - /home/$USER/docker/appdata/lidarr/cache:/cache
  radarr:
    container_name: radarr
    image: ghcr.io/hotio/radarr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 7878:7878
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/radarr/config:/config
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/radarr/logs:/logs
      - /home/$USER/docker/appdata/radarr/cache:/cache
  sonarr:
    container_name: sonarr
    image: ghcr.io/hotio/sonarr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 8989:8989
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/sonarr/config:/config
      - /home/$USER/data:/data
      - /home/$USER/docker/appdata/sonarr/logs:/logs
      - /home/$USER/docker/appdata/sonarr/cache:/cache
  bazarr:
    container_name: bazarr
    image: ghcr.io/hotio/bazarr:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 6767:6767
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/bazarr/config:/config
      - /home/$USER/data/media:/data/media
      - /home/$USER/docker/appdata/bazarr/logs:/logs
      - /home/$USER/docker/appdata/bazarr/cache:/cache
  sabnzbd:
    container_name: sabnzbd
    image: ghcr.io/hotio/sabnzbd:latest
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    ports:
      - 8080:8080
      - 9090:9090
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /home/$USER/docker/appdata/sabnzbd/config:/config
      - /home/$USER/data/usenet:/data/usenet:rw
      - /home/$USER/docker/appdata/sabnzbd/logs:/logs
      - /home/$USER/docker/appdata/sabnzbd/cache:/cache
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
    networks:
      - starr-apps
    cap_add:
      - NET_ADMIN
    environment:
      - VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=${WG_PRIVATE_KEY}
      - WIREGUARD_ADDRESSES=${WG_ADDRESSES}
      - WIREGUARD_PUBLIC_KEY=${WG_PUBLIC_KEY}
      - WIREGUARD_ENDPOINT_IP=${WG_ENDPOINT_IP}
      - WIREGUARD_ENDPOINT_PORT=${WG_ENDPOINT_PORT}
      - WIREGUARD_PRESHARED_KEY=${WG_PRESHARED_KEY} # Optional: Uncomment if you use a preshared key
      - FIREWALL_VPN_INPUT_PORTS=6881
    ports:
      - 8888:8888/tcp # Gluetun web UI
      - 6881:6881
      - 6881:6881/udp
    volumes:
      - /home/$USER/docker/appdata/gluetun/config:/gluetun
      - /etc/localtime:/etc/localtime:ro
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent
    container_name: qbittorrent
    depends_on:
      - gluetun
    network_mode: service:gluetun # Routes traffic through gluetun
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=your_timezone
      - WEBUI_PORT=8082
    volumes:
      - /home/$USER/docker/appdata/qbittorrent/config:/config
      - /home/$USER/data/torrents:/downloads:rw
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: unless-stopped
    networks:
      - starr-apps
    command: --cleanup --interval 86400
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    labels:
      - com.centurylinklabs.watchtower.enable=true
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
networks:
  starr-apps:
    external: true
```

## 🔌 Default Ports

- Jellyfin: 8096
- Jellyseerr: 5055
- Prowlarr: 9696
- Whisparr: 6969
- Stash: 9999
- Lidarr: 8686
- Radarr: 7878
- Sonarr: 8989
- Bazarr: 6767
- SABnzbd: 8080, 9090
- qBittorrent: (via Gluetun 8082)
- Gluetun UI: 8888

## 🛠️ Configuration

### GPU Passthrough

Jellyfin is configured with GPU passthrough. Ensure your system's render group ID matches the configuration (default: 122).

### User/Group Permissions

All services run with:

- PUID=1000
- PGID=1000
- Timezone: your_timezone

Adjust these values in docker-compose.yml if needed.

### Data Paths

- Configurations: `/home/$USER/docker/appdata/{service}/config`
- Media: `/home/$USER/data`
- Logs: `/home/$USER/docker/appdata/{service}/logs`
- Cache: `/home/$USER/docker/appdata/{service}/cache`

### VPN Configuration

qBittorrent traffic is routed through Gluetun VPN. Configure your VPN credentials in the `.env` file.

### Automatic Updates

Watchtower is configured to check for updates daily and automatically update containers.

## 🔒 Security Notes

1. All services use the `starr-apps` network for isolation
2. qBittorrent traffic is routed through VPN
3. Default configurations use secure settings
4. Regular updates via Watchtower

## 📝 Maintenance

- Logs are automatically rotated (max 10 files, 2MB each)
- Watchtower performs daily updates
- Monitor disk space regularly
- Backup configuration directories periodically

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
