+++
date = '2025-07-25T19:15:06-04:00'
draft = false
title = 'About Me'
tags = ['about']
categories = ['about']
layout = 'simple'
+++

I build the infrastructure and write the code that runs on it. Not one or the other..both. From bare-metal Linux servers through container orchestration to the full-stack applications on top, I own the entire vertical.

My background is 20+ years in **operations and technology** — managing systems for Disney vendors, defense contractors, and live entertainment companies. That experience taught me something most developers never learn firsthand: the best code in the world doesn't matter if the infrastructure under it is fragile. And the best infrastructure doesn't matter if nobody builds anything meaningful on it.

---

## 🔧 What I Build and Operate

- 🔹 **Infrastructure & Fleet Management**
  A 15-node production platform spanning **Proxmox** hypervisors, **LXC** containers, and geographically distributed VPS hosts — managed through a custom control plane I wrote in **Python/FastAPI** with automated backups (GFS rotation), firewall management (**nftables**), DNS/DHCP administration, and **CrowdSec** security posture scanning.

- 🔹 **Full-Stack Applications**
  Production web applications built with **FastAPI**, **React**, **Next.js**, and **PostgreSQL/PostGIS** — deployed on self-managed infrastructure with **HAProxy** reverse proxy, **Unbound** DNS, and **systemd** service management. Every app ships with encryption at rest, automated failover, and security hardened by default.

- 🔹 **AI Engineering & Automation**
  Multi-agent AI systems using **Claude API**, **Ollama**, and **Whisper** — cost-aware model routing (picking the right model for the task, not the most expensive one), automated data pipelines with self-learning search term discovery, and an AI-powered operations assistant with jailbreak guardrails and a strict action allowlist.

- 🔹 **Networking & Security**
  Enterprise-grade networking with **OPNsense** firewalls, **HAProxy** reverse proxies, **WireGuard** VPN tunnels, **Cloudflare** Tunnel integration, and **Authentik** SSO — all managed programmatically via REST APIs. Security isn't an afterthought..it's the foundation.

---

## 📊 Data & Analytics

The operations background never left. I still think in terms of **SQL** queries, **Tableau** dashboards, and **Grafana** panels. The difference now is that I also build the infrastructure those tools run on and the pipelines that feed them data.

---

## 💡 My Mindset

I think in systems. Every problem is a set of dependencies, constraints, and interfaces. The goal isn't just to make something work — it's to make something that works *and* that you can reason about six months from now when it breaks at 2 AM.

I'm a dedicated builder of open-source tools, a continuous learner who'd rather understand the foundational principles than memorize the framework of the month, and a firm believer that technology's real value is measured by the problems it solves..not by how impressive it sounds on a slide deck.
