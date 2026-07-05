#!/bin/bash

driver_path="/data/etc"
driver_name="modbus-proxy"
proxy_release_tag="main-83d841d"
proxy_archive="modbus-proxy-rs-armv7-unknown-linux-gnueabihf.tar.gz"

echo ""
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


url="https://github.com/dominikandreas/venus-modbus-proxy/archive/refs/heads/master.zip"

binary_url="https://github.com/dominikandreas/modbus-proxy-rs/releases/download/${proxy_release_tag}/${proxy_archive}"

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
    echo "Backing up existing config and cleaning up existing driver..."
    if [ -f ${driver_path}/${driver_name}/config.yaml ]; then
        cp ${driver_path}/${driver_name}/config.yaml /tmp/${driver_name}.config.yaml
    fi
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
if [ -f /tmp/${driver_name}.config.yaml ]; then
    echo ""
    echo "Restoring existing config file..."
    mv /tmp/${driver_name}.config.yaml ${driver_path}/${driver_name}/config.yaml
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

echo ""
echo "Downloading modbus-proxy-rs ${proxy_release_tag}..."
wget -O /tmp/${proxy_archive} "$binary_url"
tar -xzf /tmp/${proxy_archive} -C /tmp
cp /tmp/modbus-proxy-rs-armv7-unknown-linux-gnueabihf/modbus-proxy-rs ${driver_path}/${driver_name}/modbus-proxy
chmod 755 ${driver_path}/${driver_name}/modbus-proxy
rm -rf /tmp/${proxy_archive} /tmp/modbus-proxy-rs-armv7-unknown-linux-gnueabihf


# copy default config file
if [ ! -f ${driver_path}/${driver_name}/config.yaml ]; then
    echo ""
    echo ""
    echo "First installation detected. Copying default config file..."
    echo ""
    echo "** Do not forget to edit the config file with your settings! **"
    echo "You can edit the config file with the following command:"
    echo "nano ${driver_path}/${driver_name}/config.yaml"
    cp ${driver_path}/${driver_name}/config.sample.yaml ${driver_path}/${driver_name}/config.yaml
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
