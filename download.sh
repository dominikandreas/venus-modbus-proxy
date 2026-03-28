#!/bin/bash

driver_path="/data/etc"
driver_name="modbus-proxy"

echo ""
echo ""

# fetch version numbers for different versions
echo -n "Fetch current version numbers..."

version=$(curl -s https://api.github.com/repos/dominikandreas/venus-modbus-proxy/releases/latest | grep "tag_name" | cut -d : -f 2,3 | tr -d "\ " | tr -d \" | tr -d \,)

echo

echo "> Selected: $version"
echo ""


echo ""
if [ -d ${driver_path}/${driver_name} ]; then
    echo "Updating driver '$driver_name' as '$driver_name'..."
else
    echo "Installing driver '$driver_name' as '$driver_name'..."
fi


# change to temp folder
cd /tmp

# download driver
echo ""
echo "Downloading driver..."


## latest release
if [ -n "$version" ]; then
    # download latest release
    url=$(curl -s https://api.github.com/repos/dominikandreas/venus-modbus-proxy/releases/latest | grep "zipball_url" | sed -n 's/.*"zipball_url": "\([^"]*\)".*/\1/p')
fi

binary_url=https://github.com/dominikandreas/modbus-proxy-rs/releases/download/main-4bd745e/modbus-proxy-rs-armv7l-linux

echo "Downloading from: $url"
wget -O /tmp/venus-modbus-proxy.zip "$url"

# check if download was successful
if [ ! -f /tmp/venus-modbus-proxy.zip ]; then
    echo ""
    echo "Download failed. Exiting..."
    exit 1
fi


# If updating: cleanup old folder
if [ -d /tmp/venus-modbus-proxy-master ]; then
    rm -rf /tmp/venus-modbus-proxy-master
fi


# unzip folder
echo "Unzipping driver..."
unzip venus-modbus-proxy.zip

# Find and rename the extracted folder to be always the same
extracted_folder=$(find /tmp/ -maxdepth 1 -type d -name "*${driver_name}-*")

# Desired folder name
desired_folder="/tmp/venus-modbus-proxy-master"

# Check if the extracted folder exists and does not already have the desired name
if [ -n "$extracted_folder" ]; then
    if [ "$extracted_folder" != "$desired_folder" ]; then
        mv "$extracted_folder" "$desired_folder"
    else
        echo "Folder already has the desired name: $desired_folder"
    fi
else
    echo "Error: Could not find extracted folder. Exiting..."
    exit 1
fi


# If updating: cleanup existing driver
if [ -d ${driver_path}/${driver_name} ]; then
    echo ""
    # get confirmation from user
    read -p "Do you want to remove the existing driver files? [y/N]: " remove_driver
    if [ "$remove_driver" != "y" ] && [ "$remove_driver" != "Y" ]; then
        echo "Exiting..."
        exit 0
    fi
    echo "Cleaning up existing driver..."
    rm -rf ${driver_path:?}/${driver_name}
fi


# copy files
echo ""
echo "Copying new driver files..."
cp -R /tmp/venus-modbus-proxy-master/${driver_name}/ ${driver_path}/${driver_name}/

# remove temp files
echo ""
echo "Cleaning up temp files..."
rm -rf /tmp/venus-modbus-proxy.zip
rm -rf /tmp/venus-modbus-proxy-master



# If updating: restore existing config file
if [ -f ${driver_path}/${driver_name}_config.ini ]; then
    echo ""
    echo "Restoring existing config file..."
    mv ${driver_path}/${driver_name}_config.ini ${driver_path}/${driver_name}/config.ini
fi


# set permissions for files
echo ""
echo "Setting permissions for files..."
chmod 755 ${driver_path}/${driver_name}/modbus-proxy
chmod 755 ${driver_path}/${driver_name}/install.sh
chmod 755 ${driver_path}/${driver_name}/restart.sh
chmod 755 ${driver_path}/${driver_name}/uninstall.sh
chmod 755 ${driver_path}/${driver_name}/service/run
chmod 755 ${driver_path}/${driver_name}/service/log/run

wget -O ${driver_path}/${driver_name}/modbus-proxy $binary_url
chmod 755 ${driver_path}/${driver_name}/modbus-proxy


# copy default config file
if [ ! -f ${driver_path}/${driver_name}/config.ini ]; then
    echo ""
    echo ""
    echo "First installation detected. Copying default config file..."
    echo ""
    echo "** Do not forget to edit the config file with your settings! **"
    echo "You can edit the config file with the following command:"
    echo "nano ${driver_path}/${driver_name}/config.ini"
    cp ${driver_path}/${driver_name}/config.sample.ini ${driver_path}/${driver_name}/config.ini
    echo ""
    echo "** Execute the install.sh script after you have edited the config file! **"
    echo "You can execute the install.sh script with the following command:"
    echo "bash ${driver_path}/${driver_name}/install.sh"
    echo ""
else
    echo ""
    echo "Restart driver to apply new version..."
    /bin/bash ${driver_path}/${driver_name}/restart.sh
fi


echo
echo "Done."
echo
echo