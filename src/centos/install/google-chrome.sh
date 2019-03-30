#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Chromium Browser"
cd /tmp

#sudo yum install -y libindicator3-7 indicator-application libnss3-nssdb libnss3 libnspr4 libappindicator3-1 fonts-liberation xdg-utils

# Type the following command to download 64 bit version of Google Chrome:
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

cat /etc/yum.repos.d/google-chrome.repo

# Install Google Chrome and its dependencies on a CentOS/RHEL, type:
sudo yum install -y ./google-chrome-stable_current_*.rpm

sudo yum update -y google-chrome-stable

#echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init



