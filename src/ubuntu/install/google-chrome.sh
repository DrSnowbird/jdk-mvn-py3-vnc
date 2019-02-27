#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Chromium Browser"
cd /tmp
sudo apt-get install -y libindicator3-7 indicator-application libnss3-nssdb libnss3 libnspr4 libappindicator3-1 fonts-liberation
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
which google-chrome
rm google-chrome-stable_current_amd64.deb

echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init
