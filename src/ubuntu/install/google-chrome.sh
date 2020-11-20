#!/usr/bin/env bash
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
sudo apt-get install -y libindicator3-7 indicator-application libnss3-dev libnss3-tools libnss3 libnspr4 libappindicator3-1 fonts-liberation xdg-utils libgbm1 libu2f-udev

#### ---- Install Google-Chrome ---- ####
function install_google_chrome() {
    #sudo apt install -y gdebi-core wget
    sudo wget -c -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    #sudo gdebi google-chrome-stable_current_amd64.deb
    ##cat /etc/apt/sources.list.d/google-chrome.list
    which google-chrome
    sudo rm google-chrome-stable_current_amd64.deb
}
if [ "`which google-chrome`" = "" ]; then
    install_google_chrome
fi

function add_mode_lib_for_chrome() {
    sudo apt-get install -y apt-utils packagekit-gtk3-module libcanberra-gtk3-module
    echo "CHROMIUM_FLAGS='--no-sandbox --no-gpu --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init
    sudo apt-get install -y xvfb openbox tint2 xfce4-panel xfce4-notifyd xfce4-whiskermenu-plugin compton feh conky-all
    # -- fix missing libs --
    sudo apt-get update -y --fix-missing

    sudo /etc/init.d/dbus restart
    sudo service dbus start
    sudo service dbus status
    #sudo systemctl enable dbus
}
add_mode_lib_for_chrome

sudo chown -R ${USER}:${USER} $HOME/*

CHROME_EXE=/usr/bin/google-chrome
function change_chrome_with_no_sandbox() {

    ## setup --no-sandbox for google-chrome replacement
    echo ">>> /opt/google/chrome/google-chrome: ... beofre modifying\n"
    cat ${CHROME_EXE}
    sudo cp ${CHROME_EXE} ${CHROME_EXE}.ORIG

    cat >./google-chrome <<-EOF
#!/bin/bash
${CHROME_EXE}.ORIG --no-sandbox --disable-setuid-sandbox --disable-gpu $*
EOF
    sudo cp ./google-chrome ${CHROME_EXE}
    echo ">>> ${CHROME_EXE}: ... AFTER modifying\n"
    cat ${CHROME_EXE}
}
#change_chrome_with_no_sandbox


sudo apt-get autoremove -y

