---
layout: home
---

We use Couscous generates a [GitHub pages](http://pages.github.com/) website from your markdown documentation.

# Contribution Guide

1. Add new documentation markdown files to the root directory
2. Images path will be to the root of the website (/images/<yourimage.png>)
3. All files names should be lowercase and no spaces
4. Image file names should be .png and **NOT** .PNG


## Steps to run Couscous on Windows 10

### 1. Install bash on Windows 10
[Bash on Windows article](http://www.windowscentral.com/how-install-bash-shell-command-line-windows-10)

### 2. Get couscous working on bash shell
[Getting Started](http://couscous.io/docs/getting-started.html)

### 3. Install PHP7x using Bash on Windows

1. Install Pre-requisites > On bash prompt

    ```bash
    sudo apt-get install build-essential libxml2-dev
    ```



2. Install php and git
    ```bash
    sudo apt-get install -y git php7.0
    ```


3. Get php packages and install
```bash
sudo apt-add-repository ppa:ondrej/php
sudo apt install unzip zip
sudo apt-get install -y git php7.0-curl php7.0-xml php7.0-mbstring php7.0-gd php7.0-sqlite3 php7.0-mysql
```

    
4. Install NPM and bower
	```bash
    sudo apt-get install composer
	composer update
	sudo apt-get install npm 
	sudo npm install -g bower
	sudo npm install -g less less-plugin-clean-css
    ```

	if the npm install fails, then likely the nodejs is not syslinked to node. Run the following command to fix it
	
    ```bash
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    ```
### 4. Install Couscous using composer
```bash
composer global require couscous/couscous
```
if couscous install fails , then likely user does not have permissiosn on `.composer` directory. Run the following command to fix it
```bash
sudo chown -R $USER ~/.composer/
```
### 4. Run couscous from the bash window

You might have to Change directory  mount the folder to the
	
```bash
cd /mnt/c/<path_to_docs_cloudneeti>
couscous preview
```
If couscous fails to generate files due to permissions on directory, then run following command.
```bash
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \;
```

Verify your changes on the browser. Most likely the URL would be http://127.0.0.1:8000/deployment-guide.html


### 5. Deploy to gh_pages

The following command will push the generated files to gh_pages branch

```bash
couscous deploy
```
The Follwing command will delete all files generated by couscous

```bash
couscous clear
```
	

