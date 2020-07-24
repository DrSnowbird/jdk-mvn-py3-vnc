#!/bin/bash -x

set -e

env

whoami

echo "Install Firefox"

## -- ref: https://tecadmin.net/install-firefox-on-linux/

# Step 1 – Remove Existing Version
#sudo yum remove -y firefox          #Redhat based systems 
#sudo dnf remove -y firefox          #Fedora 22+ systems 

#Also, unlink or rename the current firefox binary (if available). For example, your current binary location is /usr/bin/firefox.

if [ -s /usr/bin/firefox ]; then
    sudo unlink /usr/bin/firefox        ## Or rename file 
    sudo rm -f /usr/bin/firefox /usr/bin/firefox_bak
fi

# Step 2 – Download Latest Firefox for Linux
# Download the latest Firefox archive from here. At the time of the last update of this article, Firefox 699 is the latest stable version available. Download Firefox source code as per your system architecture using one of the following commands.

FIREFOX_VERSION=${FIREFOX_VERSION:-68.9.0esr}
#FIREFOX_VERSION=${FIREFOX_VERSION:-78.0.2}

cd /opt

FIREFOX_HOME=/opt/firefox

# https://ftp.mozilla.org/pub/firefox/releases/68.9.0esr/linux-x86_64/en-US/firefox-68.9.0esr.tar.bz2
# https://ftp.mozilla.org/pub/firefox/releases/79.0b9/linux-x86_64/en-US/firefox-79.0b9.tar.bz2
# https://ftp.mozilla.org/pub/firefox/releases/78.0.2/linux-x86_64/en-US/firefox-78.0.2.tar.bz2
sudo wget -cq --no-check-certificate https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2


#After downloading the latest version of Firefox archive on your system, let’s extract the archive using the following command.

sudo tar xvjf firefox-${FIREFOX_VERSION}.tar.bz2

# Step 3 – Install Firefox on Linux
# Firefox source is completely pre-compiled and we don’t have to do anything to make it running on the system. Here install Firefox means to configure Firefox to work on your system. You just need to create a soft-link of Firefox binary file to systems bin directory to make it accessible from anywhere in the system.

sudo ln -s ${FIREFOX_HOME}/firefox /usr/bin/firefox

ls -al ${FIREFOX_HOME}/firefox /usr/bin/firefox

cat <<EOF> ~/Desktop/firefox-latest.desktop

[Desktop Entry]
Version=1.0
Name=Firefox Qurantum Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Path=/home/developer
Icon=${FIREFOX_HOME}/browser/chrome/icons/default/default64.png
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
Actions=NewWindow;NewPrivateWindow;

Name[en_US]=firefox-latest.desktop

[Desktop Action NewWindow]
Name=Open a New Window
Exec=firefox -new-window

[Desktop Action NewPrivateWindow]
Name=Open a New Private Window
Exec=firefox -private-window
EOF

sudo cp ~/Desktop/firefox-latest.desktop /usr/share/applications/

