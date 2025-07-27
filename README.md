# 🌐 Source Code for My Personal Website

This repository contains the source code for my personal website, live at [www.russmorefield.com](https://www.russmorefield.com).

The site is built using the **Hugo** static site generator and the beautiful **Blowfish** theme. It is automatically deployed to **GitHub Pages** whenever changes are pushed to the `main` branch.

---

## 🚀 Tech Stack

- **Static Site Generator:** [Hugo (Extended Version)](https://gohugo.io/)
- **Theme:** [Blowfish](https://blowfish.page/)
- **Hosting:** GitHub Pages
- **Deployment:** GitHub Actions
- **DNS & CDN:** Cloudflare

---

## 💻 Local Development

To run this website locally for development or to add new content, you will need to have **Git** and the **extended version of Hugo** installed on your system.

### 1. Clone the Repository

Clone this repository with the `--recurse-submodules` flag to ensure the Blowfish theme is included:

```bash
git clone --recurse-submodules https://github.com/russmorefield/russmorefield.github.io.git
```

If you've already cloned the repo without submodules, run:

```bash
git submodule update --init --recursive
```

### 2. Run the Hugo Server

Navigate into the directory and start the Hugo development server:

```bash
cd russmorefield.github.io
hugo server
```

To view drafts while editing, add the `-D` flag:

```bash
hugo server -D
```

### 3. Preview the Site

Open your browser and visit:

```
http://localhost:1313/
```

Changes you make will hot reload in real time.

---

## ✍️ Adding Content

- **New Pages** (e.g., About, Contact):

```bash
hugo new content/<page-name>.md
```

- **New Blog Posts**:

```bash
hugo new content/posts/<post-name>.md
```

> 💡 Be sure to set `draft = false` in the front matter to make your new content publicly visible.

---

## ⚙️ Deployment

This site uses GitHub Actions for **continuous deployment**.

Any commit pushed to the `main` branch will:

1. Build the Hugo site.
2. Deploy the static files to **GitHub Pages**.

You can find the deployment status under the **Actions** tab of this repository.

---

### 🛠 Maintained by [Russell Morefield](https://www.russmorefield.com)
