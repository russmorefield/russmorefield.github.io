# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal website for Russell Morefield at **www.russmorefield.com**. Hugo static site with the Blowfish theme, deployed to GitHub Pages via GitHub Actions on push to `master`.

## Commands

```bash
# Initialize submodules (required after fresh clone)
git submodule update --init --recursive

# Local dev server (http://localhost:1313)
hugo server

# Dev server with drafts visible
hugo server -D

# Production build
hugo --minify

# Create new blog post (page bundle pattern)
mkdir -p content/posts/<slug> && hugo new content posts/<slug>/index.md

# Create standalone page
hugo new content <page-name>.md

# Update Blowfish theme
git submodule update --remote --merge
```

Hugo Extended is required (v0.148.1 pinned in CI). If not installed locally, use `scripts/wsl-hugo-bootstrap.sh` for WSL setup.

## Architecture

### Config Split

All Hugo configuration lives in `config/_default/` as separate TOML files (Blowfish convention):

| File | Controls |
|---|---|
| `hugo.toml` | Site title, baseURL, taxonomies, outputs, sitemap |
| `params.toml` | Theme behavior: layout, colors, header/footer, homepage, article display, Firebase analytics, author bio |
| `languages.en.toml` | Language settings, logo paths, author details, social links |
| `menus.en.toml` | Header nav (Posts, Tableau Portfolio, About Me) and footer nav (Tags, Categories) |
| `markup.toml` | Goldmark renderer (unsafe HTML enabled), syntax highlighting, TOC levels |
| `module.toml` | Empty — reserved for Hugo modules |

### Content Structure

Posts use Hugo **page bundles** — each post is a directory containing `index.md` + a `featured.{png,jpg}` image:

```
content/
├── about.md              # Standalone page (layout: simple)
├── tableau.md            # Tableau embed page (layout: simple)
└── posts/
    └── <slug>/
        ├── index.md      # Post content
        └── featured.png  # Hero/card image
```

### Front Matter

Posts use TOML (`+++`) front matter. Required fields:

```toml
+++
date = '2025-07-27T21:11:29-04:00'
draft = false
title = 'Post Title'
tags = ['tag1', 'tag2']
categories = ['category']   # note: "categories" not "catagories"
layout = 'post'
summary = 'Brief description'  # note: "summary" not "summmary"
+++
```

Standalone pages use `layout = 'simple'`.

### Deployment

- **Branch:** `master` (not main) — pushes trigger `.github/workflows/hugo.yml`
- **Build:** Hugo Extended 0.148.1 + Dart Sass, uploads to GitHub Pages
- **DNS:** Cloudflare DNS-only (grey cloud) → GitHub Pages. Custom domain via `static/CNAME`
- **Versioning:** Manual via Actions tab → "Bump Version" workflow (patch/minor/major). Current: 1.0.4

### Theme

Blowfish is a git submodule at `themes/blowfish` tracking `main` branch. Do not edit theme files directly — use `assets/css/` for custom CSS overrides and `config/_default/params.toml` for theme configuration.

### Assets

- `assets/img/` — Site images (logos, backgrounds, author photo) processed by Hugo Pipes
- `static/img/` — Favicon only (served as-is, no processing)
- Post images go inside the post's page bundle directory

### Firebase / Analytics

View counting (showViews/showLikes) uses Firebase. Config is in `params.toml` under `[firebase]`. The Firebase project is `russmorefield-hugo`.

## Content Style

- Blog posts are technical tutorials targeting intermediate practitioners
- Emoji headings are used throughout (e.g., `## 🚀 Step 1: ...`)
- Step-by-step format with code blocks, callout blockquotes (`> 💡`), and horizontal rules between sections
- Friendly but authoritative voice
