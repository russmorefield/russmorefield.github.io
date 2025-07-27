# Source Code for My Personal Website

This repository contains the source code for my personal website, live at [**www.russmorefield.com**](https://www.russmorefield.com).

The site is built using the [Hugo](https://gohugo.io/) static site generator and the beautiful [Blowfish](https://blowfish.page/) theme. It is automatically deployed to [GitHub Pages](https://pages.github.com/) whenever changes are pushed to the `main` branch.

---

## 🚀 Tech Stack

* **Static Site Generator:** [Hugo (Extended Version)](https://gohugo.io/)
* **Theme:** [Blowfish](https://github.com/nunocoracao/blowfish)
* **Hosting:** [GitHub Pages](https://pages.github.com/)
* **Deployment:** [GitHub Actions](https://github.com/features/actions)
* **DNS & CDN:** [Cloudflare](https://www.cloudflare.com/)

## Versioning

[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/russmorefield/russmorefield.github.io)](https://github.com/russmorefield/russmorefield.github.io/tags)

This project uses an automated GitHub Actions workflow to manage versioning. To create a new version, navigate to the **Actions** tab, select the **Bump Version** workflow, and run it. This will automatically increment the version number in the `VERSION` file, commit the change, and create a new Git tag.

---

## 💻 Local Development

To run this website locally for development or to add new content, you will need to have Git and the **extended** version of Hugo installed on your system.

### 1. Clone the Repository

First, clone this repository to your local machine. Because the Blowfish theme is included as a Git submodule, you must use the `--recurse-submodules` flag to ensure the theme is downloaded as well.

```bash
git clone --recurse-submodules [https://github.com/russmorefield/russmorefield.github.io.git](https://github.com/russmorefield/russmorefield.github.io.git)
```

If you have already cloned the repository without the submodules, you can initialize them by running this command from the project's root directory:

```bash
git submodule update --init --recursive
```

### 2. Run the Hugo Server

Navigate into the cloned directory and start the Hugo development server.

```bash
cd russmorefield.github.io
hugo server
```

To view draft posts and pages, use the `-D` flag:

```bash
hugo server -D
```

### 3. Preview the Site

Once the server is running, you can view a live preview of the website by opening your web browser and navigating to:

**[http://localhost:1313/](http://localhost:1313/)**

The site will automatically refresh in your browser whenever you save a change to a file.

---

## ✍️ Adding Content

* **New Pages:** To create a new standalone page (like an "About" or "Contact" page), run:
    ```bash
    hugo new content <page-name>.md
    ```
* **New Blog Posts:** To create a new blog post, run:
    ```bash
    hugo new content posts/<post-name>.md
    ```

Remember to set `draft = false` in the front matter of a page or post to make it visible on the live site.

---

## ⚙️ Automated Deployment

This site is configured for continuous deployment. Any commit pushed to the `main` branch will automatically trigger a GitHub Actions workflow that builds the Hugo site and deploys the static files to GitHub Pages.
