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
    image: "<img-url>" # Replace with your image URL
    alt: "Starr Apps Stack Banner"
    caption: "Complete Media Server Stack"
    relative: false
    hidden: false
---

# 🌟 Starr Apps Stack

A comprehensive media server stack featuring Jellyfin, the *arr suite, and supporting applications for a complete home media solution.

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

## 🚀 Prerequisites

1. Docker and Docker Compose installed
2. Create the required network:

   ```bash
   docker network create starr-apps
   ```

3. Required directory structure:

   ```plaintext
   /home/$USER/docker/appdata/
   /home/$USER/data/
   ```

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
