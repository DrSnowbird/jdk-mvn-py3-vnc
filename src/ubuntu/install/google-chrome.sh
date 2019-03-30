#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Chromium Browser"
cd /tmp
                                          
sudo apt-get install -y libindicator3-7 indicator-application libnss3-nssdb libnss3 libnspr4 libappindicator3-1 fonts-liberation xdg-utils

wget -q -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo dpkg -i google-chrome-stable_current_amd64.deb

which google-chrome

rm google-chrome-stable_current_amd64.deb

echo "CHROMIUM_FLAGS='--no-sandbox --no-gpu --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init

sudo apt-get install -y xvfb openbox obmenu tint2 xfce4-panel xfce4-notifyd xfce4-whiskermenu-plugin compton feh conky-all

sudo /etc/init.d/dbus restart
sudo service dbus start
sudo service dbus status
sudo systemctl enable dbus

sudo chown -R ${USER}:${USER} $HOME/.config

sudo apt autoremove -y

