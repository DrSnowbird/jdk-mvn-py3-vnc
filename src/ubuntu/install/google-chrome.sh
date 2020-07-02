#!/bin/bash -x
##!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Chromium Browser"
cd /tmp
                                          
sudo apt-get update -y 
sudo apt-get upgrade -y 

# -- patch (work-around) fix to prevent 
#echo "Set disable_coredump false" | sudo tee -a /etc/sudo.conf

# (Ubuntu 16.04 only)
# sudo apt-get install -y libindicator3-7 indicator-application libnss3-nssdb libnss3 libnspr4 libappindicator3-1 fonts-liberation xdg-utils
sudo apt-get install -y libindicator3-7 indicator-application libnss3-dev libnss3-tools libnss3 libnspr4  libappindicator3-1 fonts-liberation xdg-utils libgbm1 libu2f-udev

wget -q -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo apt-get install -y ./google-chrome-stable_current_amd64.deb

which google-chrome

rm google-chrome-stable_current_amd64.deb

echo "CHROMIUM_FLAGS='--no-sandbox --no-gpu --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init

#sudo apt-get install -y xvfb feh openbox obmenu tint2 xfce4-panel xfce4-notifyd xfce4-whiskermenu-plugin compton conky-all

sudo apt-get install -y xvfb feh openbox tint2 xfce4-panel xfce4-notifyd xfce4-whiskermenu-plugin compton conky-all

sudo /etc/init.d/dbus restart
sudo service dbus start
sudo service dbus status
sudo systemctl enable dbus

sudo chown -R ${USER}:${USER} $HOME/.config

## setup --no-sandbox for google-chrome replacement
sudo cp /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome.ORIG

cat >./google-chrome <<-EOF
#!/bin/bash
/opt/google/chrome/google-chrome.ORIG --no-sandbox --disable-gpu $*
EOF
sudo cp ./google-chrome /opt/google/chrome/google-chrome

sudo apt-get autoremove -y

