#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

os_name=centos
function detectOS_alt() {
    os_name="`which yum`"
    if [ "$os_name" = "" ]; then
        os_name="`which apt`"
        if [ "$os_name" = "" ]; then
            OS_TYPE=0
            echo "*** ERROR ***: Unsupported OS type! Abort!"
            exit 1
        else
            OS_TYPE=ubuntu
        fi
    else
        OS_TYPE=centos
    fi
 
}
detectOS_alt

echo "Install Google-Chrome Browser"
cd /tmp

#sudo yum install -y libindicator3-7 indicator-application libnss3-nssdb libnss3 libnspr4 libappindicator3-1 fonts-liberation xdg-utils


#cat /etc/yum.repos.d/google-chrome.repo

if [ "${OS_TYPE}" = "centos" ]; then
    # Type the following command to download 64 bit version of Google Chrome:
    wget -cq --no-check-certificate https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    # Install Google Chrome and its dependencies on a CentOS/RHEL, type:
    sudo yum install -y ./google-chrome-stable_current_*.rpm
    sudo yum update -y google-chrome-stable
    sudo rm -f ./google-chrome-stable_current_*.rpm
else
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    # Install Google Chrome and its dependencies on a Ubuntu, type:
    sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
    cat /etc/apt/sources.list.d/google-chrome.list
    sudo rm -f ./google-chrome-stable_current_*.deb
fi

#echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init

echo "To Run Google Chrome: google-chrome &"
ls -al "`which google-chrome`"
