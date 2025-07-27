+++
title = 'A Guide to Building and Deploying a Hugo Website'
date = '2025-07-27'
draft = false
tags = ['hugo', 'github', 'deployment', 'static site', 'blowfish']
categories = ['web development']
summary = 'Step-by-step guide to building a Hugo website using the Blowfish theme and deploying it on GitHub Pages.'
layout = 'post'
+++

### Introduction

#### Purpose and Scope

This guide provides an exhaustive, step-by-step tutorial for creating a personal website using the Hugo static site generator and the Blowfish theme, with final deployment and hosting on GitHub Pages. It is designed for a technical user who seeks to understand each step of the process, from configuring a local development environment to establishing a fully automated deployment pipeline. The methodology follows a "manual but best-practice" approach, utilizing core tools like Git and the Hugo command-line interface directly. This aligns with a preference for transparent, reproducible workflows over abstracted helper scripts, ensuring a deep understanding of the underlying architecture. The instructions prioritize the official, recommended methods for installation and deployment to guarantee long-term stability and maintainability.

#### Final Outcome

By following this guide, a user will first construct and launch a live website at its default `github.io` address. The guide then details how to point a custom domain (e.g., `www.your-domain.com`) to this site, resulting in a professional, fully-automated web presence built on Hugo, the Blowfish theme, and GitHub Actions.

## Part 1: Foundational Setup: Preparing Your Ubuntu 24.04 Environment

A correctly configured local environment is the critical first phase that prevents a wide range of future complications. This section details the installation and configuration of the essential tools required for this project on your Ubuntu 24.04 Desktop: Git for version control, GitHub Desktop for a graphical Git interface, Visual Studio Code as your editor, and Hugo for static site generation.

### 1.1 Installing and Configuring Your Development Toolkit

This project relies on a specific set of tools working together. The following steps will guide you through installing Git, GitHub Desktop, and Visual Studio Code on your Ubuntu 24.04 system.

#### 1.1.1 Installing Git

Git is a non-negotiable prerequisite for this project. Its use is mandated by both Hugo and the Blowfish theme for critical functions such as installing the theme as a Git submodule and for deploying the final site to GitHub Pages. [1, 2, 3] On Ubuntu, it is best installed using the native package manager.

1. **Update Package Lists:** It is always good practice to first update the local package index. Open a terminal and run `sudo apt update`. [4]
    
2. **Install Git:** Run the following command: `sudo apt install git`. [1, 4]
    
3. **Verify Installation:** After the installation completes, run `git --version` in the terminal to verify its presence and version. [4]
    

#### 1.1.2 Installing GitHub Desktop

While Git is a command-line tool, GitHub Desktop provides a graphical user interface that can simplify day-to-day version control tasks. Since there is no official GitHub Desktop client for Linux, we will use a well-regarded community fork by ShiftKey. [5]

1. **Update Packages:** Ensure your system's package list is up to date:
    
    ```shell
    sudo apt update && sudo apt upgrade
    ```
    
    [5]
    
2. **Add the GPG Key:** This key verifies the authenticity of the software packages.
    
    ```shell
    wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /etc/apt/keyrings/mwt-desktop.gpg > /dev/null
    ```
    
    [5]
    
3. **Add the Repository:** Add the ShiftKey repository to your system's software sources.
    
    ```shell
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'
    ```
    
    [5]
    
4. **Update Package List Again:** Refresh the package list to include the new repository.
    
    ```shell
    sudo apt update
    ```
    
    [5]
    
5. **Install GitHub Desktop:** Now, install the application.
    
    ```shell
    sudo apt install github-desktop
    ```
    
    [5]
    
6. **Launch the Application:** You can now find and launch GitHub Desktop from your applications menu. [5] You will be prompted to log in to your GitHub account.
    

#### 1.1.3 Installing Visual Studio Code

Visual Studio Code (VS Code) will serve as your code editor for this project. The recommended installation method for Ubuntu is to use the official Microsoft APT repository, which ensures you receive timely updates. [6]

1. **Update and Install Prerequisites:** Ensure your system is up-to-date and has the necessary packages.
    
    ```shell
    sudo apt update
    sudo apt install wget gpg apt-transport-https
    ```
    
    [6]
    
2. **Import Microsoft's GPG Key:** This step ensures the packages you download are authentic.
    
    ```shell
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
    ```
    
    [6]
    
3. **Add the VS Code Repository:** Create the repository source list file.
    
    ```shell
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    ```
    
    [6]
    
4. **Update and Install VS Code:** Refresh your package list and install the application.
    
    ```shell
    sudo apt update
    sudo apt install code
    ```
    
    [6]
    
5. **Launch VS Code:** You can now open VS Code from your applications menu or by typing `code` in the terminal. [6]
    

#### 1.1.4 Initial Git Configuration

After installing Git, a one-time configuration is required to associate a name and email address with all commits. This information is embedded in every change recorded by Git and is essential for proper attribution on platforms like GitHub. [7, 8]

Execute the following two commands in your terminal, replacing the placeholder text with the actual name and email address:

```shell
git config --global user.name "<Your Name>"
git config --global user.email "<your.email>@example.com"
```

These settings are stored globally and will be used for all Git projects on the local machine. [8]

### 1.2 Installing Hugo (The Extended Version)

The Blowfish theme is built with modern web technologies, and to ensure full compatibility and prevent future limitations, it is essential to install the **extended** version of Hugo. The extended version includes a built-in compiler for Sass, a CSS preprocessor, which is a common dependency in the Hugo ecosystem even if not used directly by the base theme. [2, 9]

For Ubuntu, the most reliable way to install and maintain the latest extended version of Hugo is through the Snap package manager. Snap packages are self-contained, easy to install, and update automatically. [10, 11]

- **Installation Command:** Open your terminal and run the following command:
    
    ```shell
    sudo snap install hugo
    ```
    
    This command installs the latest **extended** version of Hugo by default. [10, 11]
    

#### 1.2.1 Verification

After the installation process is complete, it is crucial to verify that the correct version of Hugo is installed and accessible. Open a new terminal window and run the following command:

```shell
hugo version
```

The output should display a recent version number (the Blowfish theme documentation recommends v0.126.3 or newer [2]) and, most importantly, should include the word `extended` in the description (e.g., `hugo v0.128.0-a1b2c3d4 extended linux/amd64 BuildDate...`).

## Part 2: Project Initialization: Creating the Hugo Site and Integrating Blowfish

With the necessary tools installed, the next step is to construct the foundational structure of the website. This involves using Hugo to create the project skeleton, initializing it as a Git repository, and integrating the Blowfish theme using the recommended Git submodule method.

### 2.1 Scaffolding Your New Hugo Project

The `hugo new site` command is the standardized starting point for any Hugo project, as it creates a directory structure that the Hugo engine understands and expects. [12]

A critical step for this specific project is to name the project folder to match the intended GitHub Pages URL. GitHub has a special convention for user websites: a repository named `<username>.github.io` will be served at the root of that domain. [13] Naming the project correctly from the start aligns the local development environment with the remote deployment target, enabling a simpler, single-repository workflow, which is a modern best practice.

1. **Navigate to your development directory:** Open your terminal and change to the directory where you store your projects (e.g., a `Sites` or `Projects` folder).
    
2. **Create the new site:** Execute the following command, replacing `<username>` with your GitHub username:
    
    ```shell
    hugo new site <username>.github.io
    ```
    
3. **Enter the project directory:** Immediately navigate into the newly created folder:
    
    ```shell
    cd <username>.github.io
    ```
    
4. **Open in VS Code:** You can now open this folder in Visual Studio Code to manage your project files. From the terminal, run:
    
    ```shell
    code .
    ```
    

This command generates several folders, each with a specific purpose for organizing the website. [12]

|   |   |
|---|---|
|**Directory**|**Purpose**|
|`archetypes`|Contains templates for front matter when creating new content files.|
|`config`|Holds the site's configuration files. Modern themes often use a `_default` subdirectory here.|
|`content`|All of your site's content, such as blog posts and pages, resides here.|
|`data`|Stores data files (e.g., JSON, TOML, YAML) that can be used to populate pages.|
|`layouts`|Contains the HTML templates that define the structure and look of your site.|
|`static`|Stores static assets like images, CSS, and JavaScript files that do not need processing.|
|`themes`|Where themes are placed. Each theme has its own subdirectory.|

**

### 2.2 Initializing the Git Repository

To use a Git-based workflow for managing the theme, the project folder itself must be a Git repository. This allows Git to track not only the project's files but also its dependencies, such as the theme submodule. [12, 14]

In the terminal, from the root of the `<username>.github.io` directory, execute the following command:

```shell
git init
```

This command creates a hidden `.git` directory, initializing an empty Git repository in the project folder. [14]

### 2.3 Adding the Blowfish Theme via Git Submodule

The user's request for an "install without CLI" method points toward a preference for a transparent, manual installation process. The best practice for this is using a Git submodule. A submodule is a Git repository embedded inside another parent Git repository. This method links a specific commit of the theme's code to the main project, ensuring that the site build is always repeatable and is not affected by unexpected theme updates until an update is explicitly initiated. [15] This is the recommended installation method in the Blowfish documentation. [2]

From the root of the project directory, run the following command precisely as written:

```shell
git submodule add -b main https://github.com/nunocoracao/blowfish.git themes/blowfish
```

The -b main flag is an important addition. It instructs Git to track the main branch of the Blowfish theme repository. This means when you update the submodule later, it will pull the latest changes from the theme's main development branch, keeping your site up-to-date with the theme's features and fixes. [2]

This command performs two key actions:

1. It clones the Blowfish theme repository from GitHub into the `themes/blowfish` directory.
    
2. It creates a `.gitmodules` file in the project root. This file records the path and URL of the submodule, officially registering it with the parent Git repository. [8]
    

### 2.4 Applying the Blowfish Default Configuration

The Blowfish theme ships with a set of well-structured default configuration files. Using these files as a starting point is essential for the theme to function correctly and provides a clear path for future customization. [2, 16] The process involves replacing the single `hugo.toml` file generated by Hugo with the theme's more detailed configuration structure.

1. **Delete the default Hugo config file:** In the project root, remove the `hugo.toml` file. This can be done in the VS Code file explorer or via the terminal: `rm hugo.toml`
    
2. **Create the new config directory:** Hugo's modern configuration system resides in a `config` directory. Create it and its `_default` subdirectory using the terminal:
    
    ```shell
    mkdir -p config/_default
    ```
    
3. **Copy the theme's config files:** Copy all the `.toml` files from the theme's configuration directory into the project's new configuration directory.
    
    ```shell
    cp themes/blowfish/config/_default/*.toml config/_default/
    ```
    
    [2]
    
4. **Crucial Final Check:** Because the theme was installed as a submodule (and not as a Hugo Module), the site's configuration must explicitly declare which theme to use. Open the newly copied `config/_default/hugo.toml` file in VS Code and ensure the following line is present at the top. If it is commented out or missing, add it [2]:
    
    ```toml
    theme = "blowfish"
    ```
    

After these steps, the project is correctly structured with the Blowfish theme and its default configurations, ready for personalization.

## Part 3: Configuration and Local Preview

With the project structure and theme in place, the next phase involves personalizing the site's core settings and learning how to use Hugo's powerful local development server to preview changes in real-time.

### 3.1 Core Site Configuration (`config/_default/hugo.toml`)

The `config/_default/hugo.toml` file contains global settings that are fundamental to the Hugo engine's operation. The most critical of these is the `baseURL`, which must be set correctly for all generated URLs and assets to resolve properly on the live server. [17]

1. **Open the configuration file:** Using VS Code, open `config/_default/hugo.toml`.
    
2. **Set the Base URL:** Modify the `baseURL` parameter to match the final deployment URL, replacing `<username>` with your GitHub username. This value must begin with the protocol and end with a slash.
    
    ```toml
    baseURL = "https://<username>.github.io/"
    ```
    
3. **Set the Site Title:** Change the `title` parameter to a descriptive name for the website.
    
    ```toml
    title = "Your Website Title"
    ```
    
4. **Review Other Settings:** This file also contains other important Hugo settings, such as `languageCode` (which should be set to the primary language of the content, e.g., `"en"`) and `enableRobotsTXT` (which should be `true` to allow search engine crawling).
    

### 3.2 Personalizing the Theme (`config/_default/params.toml`)

The `config/_default/params.toml` file is where all theme-specific features are controlled. For a personal website, customizing the author details is a primary first step to personalize the site's appearance and metadata.

1. **Open the parameters file:** Using VS Code, open `config/_default/params.toml`.
    
2. **Configure Author Details:** Locate the `[author]` section. Fill in the relevant details for `name`, `headline`, and `bio`. For the `image` parameter, a path to an image placed in the `assets/` directory of your project can be used.
    
    ```toml
    [author]
      name = "<Your Name>"
      image = "img/profile.jpg" # Example path. You will need to create the `assets` folder in your project's root, create an `img` folder inside it, and then place your profile image there.
      headline = "Exploring Technology and Development"
      bio = "A brief biography about you."
      links = [
        { github = "https://github.com/<username>" },
        { linkedin = "https://linkedin.com/in/yourprofile" },
      ]
    ```
    
3. **Customize Social Links:** Within the `author.links` array, uncomment or add entries for relevant social media profiles. The theme includes icons for many popular services.
    

### 3.3 Running the Local Development Server

One of Hugo's most powerful features is its built-in development server. This command builds the site in memory, launches a local web server, and watches for file changes, automatically rebuilding the site and refreshing the browser whenever a file is saved. This provides an instant feedback loop that dramatically speeds up development. [18]

1. **Start the server:** From the root directory of your project (`<username>.github.io`), run the following command in the VS Code integrated terminal (`Ctrl+` `) or a separate terminal window:
    
    ```shell
    hugo server
    ```
    
2. **Preview the site:** The terminal will output a message indicating the server is running and provide a URL, typically `http://localhost:1313/`. [18] Open this URL in a web browser to see the live preview of the site.
    
3. **Experience Live Reloading:** With the server still running, make a small change to a configuration file (e.g., change the `title` in `hugo.toml`) and save the file. Observe that the terminal registers the change and the website in the browser updates automatically without needing a manual refresh.
    
4. **Stop the server:** To stop the development server, return to the terminal window where it is running and press `Ctrl+C`.
    

This local server is the primary tool for all content creation and theme customization, allowing for immediate verification of every change.

## Part 4: Creating and Managing Content

A website's structure is defined by its content. This section covers the fundamental workflows for creating two primary types of content in Hugo: a standalone, static page (like an "About" page) and a chronological blog post. Understanding the distinction is key to organizing a site effectively.

### 4.1 Creating a Standalone "About" Page

A personal website almost universally includes an "About" page. This serves as a perfect example of creating a top-level, static page that exists outside of a chronological series like a blog.

1. **Generate the page file:** Use the `hugo new` command in the terminal to create the content file. For a simple page, creating a markdown file directly in the `content` directory is the most straightforward approach.
    
    ```shell
    hugo new content/about.md
    ```
    
    This command creates a new file at `content/about.md`.
    
2. **Add content and publish the page:** Open `content/about.md` in VS Code. The file will contain a "front matter" block at the top, which holds metadata about the page. Add your content below the front matter using Markdown syntax. To make the page visible, you must also change `draft = true` to `draft = false`. [17]
    
    Here is an example of what the complete `content/about.md` file might look like:
    
    ```markdown
    +++
    title = "About Me"
    date = 2025-07-27T01:50:00-04:00
    draft = false
    +++
    
    Hello! My name is <Your Name>. Welcome to my personal website.
    
    ## My Background
    
    I am a passionate developer with a background in web technologies. I enjoy building things for the web and exploring new and exciting frameworks. This website serves as a portfolio for my projects and a place to share my thoughts on technology.
    
    ## Hobbies and Interests
    
    When I'm not coding, I enjoy:
    * Hiking in nature
    * Reading science fiction novels
    * Experimenting with new recipes
    
    Feel free to connect with me on the social media platforms linked in the header.
    ```
    

### 4.2 Adding the "About" Page to the Navigation Menu

A page is not useful if visitors cannot find it. The next step is to add a link to the newly created "About" page in the site's main navigation menu.

1. **Open the menu configuration:** Using VS Code, edit the file `config/_default/menus.en.toml`. This file controls the menu structure for the English version of the site. [16, 19]
    
2. **Add a new menu entry:** Add the following block to the file. The `pageRef` parameter tells Hugo to link to the content file located at `/about`, and `weight` determines its position in the menu (lower numbers appear first).
    
    ```toml
    [[main]]
      name = "About"
      pageRef = "/about"
      weight = 20
    ```
    
3. **Verify the change:** If the local server is running (`hugo server`), the "About" link will now appear in the site's header navigation.
    

### 4.3 Writing Your First Blog Post

This workflow demonstrates how to create time-based content, such as blog posts, which are typically organized into a "section."

1. **Generate the post file:** Use the `hugo new` command again, but this time specify the `posts` section in the path.
    
    ```shell
    hugo new content/posts/my-first-post.md
    ```
    
    This creates a file at `content/posts/my-first-post.md`, making it part of the "posts" collection.
    
2. **Add content:** Open the new file in VS Code and add content below the front matter. For this example, leave `draft = true`.
    
3. **Previewing Drafts:** By default, the `hugo server` command does not render draft content. To view drafts, the server must be started with the `-D` or `--buildDrafts` flag. Stop the current server (`Ctrl+C`) and restart it with the new command:
    
    ```shell
    hugo server -D
    ```
    
    The new post will now be visible on the site's post listing page.
    
4. **Finalize the Post:** Once the post is complete and ready for publication, open its file and change the front matter to `draft = false`. The post will now be included in regular production builds.
    

The folder structure within the `content` directory directly influences the site's URL structure and the layout templates Hugo applies. Content in the root of `content` (like `about.md`) becomes a top-level page, while content in subdirectories (like `posts/`) becomes part of a section, which can have its own unique listing pages and layouts. This organizational principle is fundamental to managing a Hugo site as it grows.

## Part 5: Automated Deployment to GitHub Pages

This final phase brings the website to life on the public internet. The process uses a modern, automated workflow with GitHub Actions. This approach, known as Continuous Integration/Continuous Deployment (CI/CD), automates the build and deployment process, eliminating manual steps and reducing the potential for error. The workflow is triggered every time a change is pushed to the project's source code repository. [3, 20]

### 5.1 Creating the Remote GitHub Repository

The first step is to create a home for the site's source code on GitHub.com. This remote repository will also serve as the hosting platform for the final GitHub Pages site.

1. **Log in to GitHub:** Access your account on `github.com`.
    
2. **Create a New Repository:** Navigate to the "New repository" page.
    
3. **Set the Repository Name:** The repository name must be exactly `<username>.github.io`. This specific naming convention is what enables GitHub User Pages hosting. [13]
    
4. **Set Visibility:** The repository must be set to **Public**.
    
5. **Initialize the Repository:** **Crucially, do not initialize the repository with a `README`, `.gitignore`, or `license` file.** The repository must be created completely empty to prevent merge conflicts when the existing local project is pushed to it for the first time.
    
6. **Click "Create repository".**
    

### 5.2 Pushing Your Site's Source Code using GitHub Desktop

With the empty remote repository created, the next step is to upload the local Hugo project to it using the GitHub Desktop application. This will publish the entire project source, including the content, configuration files, and the theme submodule.

1. **Add Local Repository:** Open GitHub Desktop. Go to the `File` menu and select `Add Local Repository...`. Navigate to and select your `<username>.github.io` project folder.
    
2. **Publish Repository:** After adding the local repository, a "Publish repository" button will appear in the main panel. Click it.
    
3. **Configure and Publish:** In the "Publish Repository" dialog:
    
    - Ensure the `Name` is `<username>.github.io`.
        
    - Make sure the `Keep this code private` checkbox is **unchecked**.
        
    - Click the `Publish Repository` button. GitHub Desktop will now push your local files to the newly created remote repository on GitHub.com.
        
4. **Future Commits:** To save and push future changes:
    
    - Make your changes in VS Code and save the files.
        
    - Switch to GitHub Desktop. Your changes will appear in the "Changes" tab.
        
    - Enter a summary for your changes in the text box at the bottom left.
        
    - Click the `Commit to main` button.
        
    - Click the `Push origin` button at the top of the window to send your committed changes to GitHub.
        

### 5.3 Implementing the GitHub Actions Deployment Workflow

The GitHub Actions workflow is the automation engine. It is defined in a YAML file that instructs GitHub on how to build and deploy the Hugo site whenever new code is pushed. [21]

1. **Create the workflow directory:** In VS Code, create a new folder structure in the root of your project: `.github/workflows`.
    
2. **Create the workflow file:** Inside the `workflows` directory, create a new file named `hugo.yml`. [21]
    
3. **Add the workflow code:** Copy and paste the following code into the `hugo.yml` file. This is the official workflow recommended by the Hugo team, providing a robust and detailed build process.
    
    ```yml
    # Sample workflow for building and deploying a Hugo site to GitHub Pages
    name: Deploy Hugo site to Pages
    
    on:
      # Runs on pushes targeting the default branch
      push:
        branches: ["main"]
    
      # Allows you to run this workflow manually from the Actions tab
      workflow_dispatch:
    
    # Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
    permissions:
      contents: read
      pages: write
      id-token: write
    
    # Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
    # However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
    concurrency:
      group: "pages"
      cancel-in-progress: false
    
    # Default to bash
    defaults:
      run:
        shell: bash
    
    jobs:
      # Build job
      build:
        runs-on: ubuntu-latest
        env:
          HUGO_VERSION: 0.128.0
        steps:
          - name: Install Hugo CLI
            run: |
              wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
              && sudo dpkg -i ${{ runner.temp }}/hugo.deb
          - name: Install Dart Sass
            run: sudo snap install dart-sass
          - name: Checkout
            uses: actions/checkout@v4
            with:
              submodules: recursive
          - name: Setup Pages
            id: pages
            uses: actions/configure-pages@v5
          - name: Install Node.js dependencies
            run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
          - name: Build with Hugo
            env:
              HUGO_CACHEDIR: ${{ runner.temp }}/hugo_cache
              HUGO_ENVIRONMENT: production
            run: |
              hugo \
                --minify \
                --baseURL "${{ steps.pages.outputs.base_url }}/"
          - name: Upload artifact
            uses: actions/upload-pages-artifact@v3
            with:
              path: ./public
    
      # Deployment job
      deploy:
        environment:
          name: github-pages
          url: ${{ steps.deployment.outputs.page_url }}
        runs-on: ubuntu-latest
        needs: build
        steps:
          - name: Deploy to GitHub Pages
            id: deployment
            uses: actions/deploy-pages@v4
    ```
    
4. **Commit and push the workflow file:** Save the `hugo.yml` file. Switch to GitHub Desktop, add a commit message like "Update GitHub Actions deployment workflow", and push the changes to origin. Pushing this file will trigger the first run of the Action.
    

### 5.4 Finalizing GitHub Pages Configuration

The final configuration step is to instruct GitHub to use the output from the newly created GitHub Action as the source for the live website.

1. **Navigate to Repository Settings:** On the GitHub repository page, go to the `Settings` tab.
    
2. **Select Pages:** In the left sidebar, click on `Pages`.
    
3. **Set the Source:** Under the "Build and deployment" section, change the `Source` dropdown from "Deploy from a branch" to **`GitHub Actions`**. [22] This change is saved automatically.
    

### 5.5 Verifying the Live Site

With the workflow configured and pushed, the deployment process is now fully automated.

1. **Monitor the Action:** Navigate to the `Actions` tab of the GitHub repository. A workflow run, triggered by the last push, should be visible.
    
2. **Wait for Completion:** The workflow will take a minute or two to complete. A successful run will be indicated by a green checkmark. If there is a red "X", it indicates a failure, and the logs can be inspected to diagnose the problem.
    
3. **Visit the Live Site:** Once the Action has completed successfully, navigate to your site at `https://<username>.github.io`. The fully deployed website should be visible. Note that it can sometimes take a few minutes for the site to become available after the very first successful deployment.
    

From this point forward, the development workflow is simplified to a single loop: make changes locally in VS Code, commit and push them with GitHub Desktop, and GitHub Actions will handle the rest, automatically building and deploying the updated site.

## Part 6: Advanced Blowfish Configuration

The Blowfish theme offers a vast array of customization options beyond the basic setup. Users are encouraged to explore the official theme documentation to learn about features such as alternative color schemes, multiple homepage layouts, advanced shortcodes, and custom partials for adding services like analytics or comments. [16, 23] This section provides an overview of how to approach these advanced customizations.

### 6.1 Customizing Color Schemes

Blowfish includes several pre-built color schemes and makes it straightforward to create your own. [24]

- **Applying a Built-in Scheme:** To change the theme, open `config/_default/params.toml` and set the `colorScheme` parameter to one of the available options, such as `avocado`, `fire`, `ocean`, or `noir`. [16, 24]
    
- **Creating a Custom Scheme:** To create a new scheme, you can add a new CSS file in the `assets/css/schemes/` directory of your project. For example, creating `assets/css/schemes/my-scheme.css` and then setting `colorScheme = "my-scheme"` in `params.toml` will apply your custom styles. This file should define CSS variables for the theme's color palette, which you can model after the theme's existing scheme files. [25]
    

### 6.2 Exploring Homepage Layouts

You can significantly alter the appearance of your homepage by choosing from several available layouts. [2, 26] This is controlled by the `homepage.layout` setting in `config/_default/params.toml`. [16]

- **`profile`:** The default layout, ideal for personal websites and blogs.
    
- **`hero`:** Displays author information along with markdown content from your `_index.md` file.
    
- **`card`:** A simple layout that shows an image and author details.
    
- **`background`:** Features a full-screen background image.
    
- **`custom`:** For complete control, this option allows you to provide your own template. To use it, you must create a file at `layouts/partials/home/custom.html` where you can define the entire homepage structure with your own HTML and Hugo templating. [27]
    

### 6.3 Utilizing Shortcodes

Shortcodes are snippets inside your content files that Hugo renders using a predefined template, allowing you to extend Markdown's capabilities. Blowfish includes a number of custom shortcodes for things like alerts, icons, and more complex layouts that are not possible with standard Markdown. [16, 28]

Here are a few of the most common and useful shortcodes:

- **Alerts:** These are perfect for drawing attention to important information. You can specify different colors for different contexts (e.g., `info`, `warning`, `danger`).
    
    ```markdown
    {{< alert "warning" >}}
    **Warning!** This action is destructive!
    {{< /alert >}}
    ```
    
### 6.4 Extending with Custom Partials

One of the most powerful features of Hugo is its file lookup order, which allows you to override any theme file without modifying the original theme source. This makes updates seamless while giving you full control. [25] You can use this to add custom partials for services like analytics or comments.

- **Adding Custom Analytics:** If you want to use an analytics provider not built into the theme, you can create a file at `layouts/partials/extend-head.html`. Any HTML, such as a tracking script, placed in this file will be automatically injected into the `<head>` section of every page. [27]
    
- **Adding a Comment System:** To add a comment system like Giscus or Commento, create a file at `layouts/partials/comments.html` and paste in the necessary code provided by the service. To enable it, you must set `showComments = true` in your `params.toml` or in the front matter of individual articles. [27]
    

## Part 7: A Detailed Guide to Connecting Your Custom Domain with Cloudflare and GitHub Pages

Connecting a custom domain involves coordinating settings between your Hugo project, GitHub, and your DNS provider (Cloudflare). This guide will configure `www.your-domain.com` as the primary address, which is a common best practice.

### 7.1 Update Your Project and GitHub Repository

First, we need to inform both your Hugo project and your GitHub repository about the new custom domain.

#### 7.1.1 Create a `CNAME` File in Your Hugo Project

GitHub Pages uses a file named `CNAME` to identify the custom domain. Placing this file in your `static` folder ensures it's correctly copied to the root of your site during every build. [30]

1. In VS Code, create a new file directly inside the `static` folder.
    
2. Name the file `CNAME` (all uppercase, no file extension).
    
3. Inside this file, add only one line of text: your custom domain with the `www` subdomain.
    
    ```
    www.your-domain.com
    ```
    
    _Note: Using `www` is recommended for greater DNS flexibility. GitHub will automatically handle redirecting the apex domain (`your-domain.com`) to the `www` version. [31]_
    

#### 7.1.2 Update Your Hugo `baseURL`

Your Hugo configuration must be updated to use the new custom domain for all generated links and assets to work correctly. [20]

1. Open your Hugo configuration file: `config/_default/hugo.toml`.
    
2. Change the `baseURL` to your new custom domain, ensuring it includes the `https://` protocol and a trailing slash.
    
    ```toml
    baseURL = "https://www.your-domain.com/"
    ```
    

#### 7.1.3 Commit and Push Your Changes

Save both the new `CNAME` file and the updated `hugo.toml`. Use GitHub Desktop to commit these changes with a message like "Configure custom domain" and push them to your `main` branch.

### 7.2 Configure DNS Records in Cloudflare

This is the most critical part of the process. You will configure two types of DNS records: `A` records, which point your root domain (`your-domain.com`) directly to GitHub's specific server IP addresses, and a `CNAME` record, which points your `www` subdomain to your existing GitHub Pages address. This separation is a standard and robust way to configure domains. [32]

#### 7.2.1 Log in to Cloudflare and Select Your Domain

1. Go to the Cloudflare dashboard and log in.
    
2. Select your domain, `your-domain.com`.
    

#### 7.2.2 Navigate to DNS Settings

In the left sidebar, click on the **DNS** icon to go to the DNS records management page.

#### 7.2.3 Delete Conflicting Records

To avoid issues, it's best to delete any existing `A`, `AAAA`, or `CNAME` records for `your-domain.com` (often shown with a name of `@`) or `www`.

#### 7.2.4 Create `A` Records for the Apex Domain (`@`)

The apex (or root) domain, `your-domain.com`, must point directly to GitHub's IP addresses using `A` records. [32] You will need to create four separate records.

For each of the four IP addresses below, click **Add record** and enter the following:

- **Type:** `A`
    
- **Name:** `@` (This represents your root domain)
    
- **IPv4 address:** Use one of the following IPs for each record [32]:
    
    - `185.199.108.153`
        
    - `185.199.109.153`
        
    - `185.199.110.153`
        
    - `185.199.111.153`
        
- **Proxy status:** Click the orange cloud to turn it **gray (DNS only)**. This is a crucial temporary step. GitHub needs to see the traffic coming directly from your domain to verify it and issue an SSL certificate. [33]
    
- Click **Save**.
    

Repeat this process until you have four `A` records, one for each IP address.

#### 7.2.5 Create a `CNAME` Record for the `www` Subdomain

Now, we'll configure the `www` subdomain.

1. Click **Add record**.
    
2. Enter the following:
    
    - **Type:** `CNAME`
        
    - **Name:** `www`
        
    - **Target:** `<username>.github.io`
        
    - **Proxy status:** Again, ensure this is set to **DNS only** (gray cloud) for now.
        
3. Click **Save**.
    

### 7.3 Finalize GitHub and Cloudflare Configuration

Now we will tie everything together and enable security features.

#### 7.3.1 Configure the Custom Domain in GitHub

1. Go back to your repository on GitHub.
    
2. Navigate to **Settings** > **Pages**.
    
3. In the "Custom domain" section, type `www.your-domain.com` and click **Save**.
    
4. GitHub will perform a DNS check. This may take a few minutes to a few hours to complete. Once successful, you will see a message indicating your site is live at the new address.
    

#### 7.3.2 Enforce HTTPS on GitHub

Once the DNS check is successful, the **Enforce HTTPS** option will become available. Check this box to ensure all traffic to your site is secure. [34] If this option is grayed out, wait a bit longer. Removing and re-adding the custom domain in the GitHub settings can sometimes speed up the certificate provisioning process.

#### 7.3.3 Set SSL/TLS Encryption Mode in Cloudflare

For the most secure connection, configure Cloudflare to encrypt traffic all the way to GitHub's servers.

1. In your Cloudflare dashboard, go to the **SSL/TLS** section.
    
2. Under the "Overview" tab, set your SSL/TLS encryption mode to **Full (strict)**. [35]
    

#### 7.3.4 Enable Cloudflare's Proxy

Now that GitHub has verified your domain, you can enable Cloudflare's performance and security features.

1. Go back to the **DNS** settings page in Cloudflare.
    
2. For each of the five records you created, click the gray cloud under "Proxy status" to turn it **orange (Proxied)**. [33]
    

Your site is now fully configured. Visitors should now be able to access your site at `https://www.your-domain.com`.

## Part 8: Conclusion and Future Exploration

### Summary of Achievements

This guide has provided a comprehensive walkthrough of the entire process for establishing a modern, personal website. A local development environment was configured on an Ubuntu 24.04 Desktop with Git, GitHub Desktop, VS Code, and the extended version of Hugo. A new Hugo project was created and integrated with the powerful Blowfish theme using a Git submodule for maintainable versioning. The site was personalized with core configuration and content, including a static "About" page and a blog post. A detailed guide for connecting a custom domain using Cloudflare was provided. Finally, and most significantly, a professional CI/CD pipeline was implemented using GitHub Actions, enabling fully automated, hands-off deployments directly to GitHub Pages. The result is a live, functional website at `https://www.your-domain.com` built on a robust and scalable foundation.

### Future Exploration

The setup detailed in this guide is a complete and production-ready starting point, but it also opens the door to further customization and learning. The following areas represent logical next steps for expanding upon this foundation:

- **Deeper Hugo Concepts:** This tutorial has covered the fundamentals of Hugo's content management. To unlock the full power of the platform, further exploration of core Hugo concepts is recommended. Key topics include taxonomies (for advanced content organization like tags and categories), shortcodes (for creating reusable content snippets within Markdown), and a deeper dive into Hugo's template lookup order and page bundles. Mastering these concepts allows for the creation of highly complex and feature-rich websites. [36]
    

## References

[1] Hugo Documentation. (n.d.). _Install Git_. Retrieved July 27, 2025, from [https://gohugo.io/installation/git/](https://www.google.com/search?q=https://gohugo.io/installation/git/ "null")

[2] Blowfish Theme Documentation. (n.d.). _Installation_. Retrieved July 27, 2025, from [https://blowfish.page/docs/installation/](https://blowfish.page/docs/installation/ "null")

[3] GitHub Docs. (n.d.). _About GitHub Pages_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages "null")

[4] Ubuntu Community Help Wiki. (2022, November 2). _AptGet/Howto_. Retrieved July 27, 2025, from [https://help.ubuntu.com/community/AptGet/Howto](https://help.ubuntu.com/community/AptGet/Howto "null")

[5] GitHub Desktop Community. (n.d.). _shiftkey/desktop repository_. Retrieved July 27, 2025, from [https://github.com/shiftkey/desktop](https://www.google.com/search?q=https://github.com/shiftkey/desktop "null")

[6] Visual Studio Code Documentation. (n.d.). _Running Visual Studio Code on Linux_. Retrieved July 27, 2025, from [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux "null")

[7] GitHub Docs. (n.d.). _Setting your username in Git_. Retrieved July 27, 2025, from [https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git](https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git "null")

[8] Chacon, S., & Straub, B. (2014). _Pro Git_ (2nd ed.). Apress. [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2 "null")

[9] Hugo Documentation. (n.d.). _Prerequisites_. Retrieved July 27, 2025, from [https://gohugo.io/getting-started/prerequisites/](https://www.google.com/search?q=https://gohugo.io/getting-started/prerequisites/ "null")

[10] Hugo Documentation. (n.d.). _Install Hugo on Linux_. Retrieved July 27, 2025, from [https://gohugo.io/installation/linux/#snap](https://www.google.com/search?q=https://gohugo.io/installation/linux/%23snap "null")

[11] Canonical Ltd. (n.d.). _Install Hugo for Linux using the Snap Store_. Retrieved July 27, 2025, from [https://snapcraft.io/hugo](https://snapcraft.io/hugo "null")

[12] Hugo Documentation. (n.d.). _Quick Start_. Retrieved July 27, 2025, from [https://gohugo.io/getting-started/quick-start/](https://gohugo.io/getting-started/quick-start/ "null")

[13] GitHub Docs. (n.d.). _About GitHub Pages - Types of GitHub Pages sites_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#types-of-github-pages-sites](https://www.google.com/search?q=https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages%23types-of-github-pages-sites "null")

[14] Chacon, S., & Straub, B. (2014). _Pro Git_ (2nd ed.). Apress. Chapter 2.1: Git Basics - Getting a Git Repository. [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2 "null")

[15] Chacon, S., & Straub, B. (2014). _Pro Git_ (2nd ed.). Apress. Chapter 7.11: Git Tools - Submodules. [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2 "null")

[16] Blowfish Theme Documentation. (n.d.). _Configuration_. Retrieved July 27, 2025, from [https://blowfish.page/docs/configuration/](https://blowfish.page/docs/configuration/ "null")

[17] Hugo Documentation. (n.d.). _Front Matter_. Retrieved July 27, 2025, from [https://gohugo.io/content-management/front-matter/](https://gohugo.io/content-management/front-matter/ "null")

[18] Hugo Documentation. (n.d.). _Basic Usage_. Retrieved July 27, 2025, from [https://gohugo.io/getting-started/usage/#development-server](https://www.google.com/search?q=https://gohugo.io/getting-started/usage/%23development-server "null")

[19] Hugo Documentation. (n.d.). _Menus_. Retrieved July 27, 2025, from [https://gohugo.io/content-management/menus/](https://gohugo.io/content-management/menus/ "null")

[20] Hugo Documentation. (n.d.). _Hosting on GitHub Pages_. Retrieved July 27, 2025, from [https://gohugo.io/hosting-and-deployment/hosting-on-github/](https://gohugo.io/hosting-and-deployment/hosting-on-github/ "null")

[21] GitHub Docs. (n.d.). _Workflow syntax for GitHub Actions_. Retrieved July 27, 2025, from [https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions "null")

[22] GitHub Docs. (n.d.). _Configuring a publishing source for your GitHub Pages site_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site "null")

[23] Blowfish Theme Documentation. (n.d.). _Getting Started_. Retrieved July 27, 2025, from [https://blowfish.page/docs/getting-started/](https://blowfish.page/docs/getting-started/ "null")

[24] Blowfish Theme Documentation. (n.d.). _Color Schemes_. Retrieved July 27, 2025, from [https://blowfish.page/docs/configuration/#color-schemes](https://www.google.com/search?q=https://blowfish.page/docs/configuration/%23color-schemes "null")

[25] Blowfish Theme Documentation. (n.d.). _Advanced Customisation - Custom CSS_. Retrieved July 27, 2025, from [https://blowfish.page/docs/advanced-customisation/#custom-css](https://www.google.com/search?q=https://blowfish.page/docs/advanced-customisation/%23custom-css "null")

[26] Blowfish Theme Documentation. (n.d.). _Homepage Layout_. Retrieved July 27, 2025, from [https://blowfish.page/docs/homepage-layout/](https://blowfish.page/docs/homepage-layout/ "null")

[27] Blowfish Theme Documentation. (n.d.). _Advanced Customisation - Partials_. Retrieved July 27, 2025, from [https://blowfish.page/docs/advanced-customisation/#partials](https://www.google.com/search?q=https://blowfish.page/docs/advanced-customisation/%23partials "null")

[28] Blowfish Theme Documentation. (n.d.). _Shortcodes_. Retrieved July 27, 2_025, from [https://blowfish.page/docs/shortcodes/](https://blowfish.page/docs/shortcodes/ "null")

[29] Blowfish Theme Documentation. (n.d.). _Shortcodes - Alert_. Retrieved July 27, 2025, from [https://blowfish.page/docs/shortcodes/#alert](https://www.google.com/search?q=https://blowfish.page/docs/shortcodes/%23alert "null")

[30] GitHub Docs. (n.d.). _Managing a custom domain for your GitHub Pages site_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site "null")

[31] GitHub Docs. (n.d.). _About custom domains and GitHub Pages_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages "null")

[32] Cloudflare Docs. (n.d.). _Manage DNS records_. Retrieved July 27, 2025, from [https://developers.cloudflare.com/dns/manage-dns-records/](https://developers.cloudflare.com/dns/manage-dns-records/ "null")

[33] Cloudflare Docs. (n.d.). _Proxied DNS records_. Retrieved July 27, 2025, from [https://developers.cloudflare.com/dns/manage-dns-records/reference/proxied-dns-records/](https://developers.cloudflare.com/dns/manage-dns-records/reference/proxied-dns-records/ "null")

[34] GitHub Docs. (n.d.). _Securing your GitHub Pages site with HTTPS_. Retrieved July 27, 2025, from [https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https](https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https "null")

[35] Cloudflare Docs. (n.d.). _SSL/TLS encryption modes_. Retrieved July 27, 2025, from [https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/ "null")

[36] Hugo Documentation. (n.d.). _Content Management_. Retrieved July 27, 2025, from [https://gohugo.io/content-management/](https://gohugo.io/content-management/ "null")