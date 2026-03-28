# Modbus-Proxy

A Venus-OS integration to run [modbus-proxy-rs](https://github.com/dominikandreas/modbus-proxy-rs), a Modbus TCP layer 7 reverse proxy. It lets multiple clients talk to Modbus devices that only support a single client, or a very small number of concurrent clients.

## Index

- [Modbus-Proxy](#Modbus-Proxy)
  - [Index](#index)
  - [Disclaimer](#disclaimer)
  - [Config](#config)
  - [Install / Update](#install--update)
    - [Extra steps for your first installation](#extra-steps-for-your-first-installation)
  - [Restart / Uninstall](#restart--uninstall)
  - [Debugging](#debugging)
  - [Compatibility](#compatibility)


## Config

Edit the config.yaml and change the defaults as required.

## Install / Update

1. Login to your Venus OS device via SSH. See [Venus OS:Root Access](https://www.victronenergy.com/live/ccgx:root_access#root_access) for more details.

2. Execute this commands to download and copy the files:

    ```bash
    wget -O /tmp/download_modbus_proxy.sh https://raw.githubusercontent.com/dominikandreas/venus-modbus-proxy/master/download.sh

    bash /tmp/download_modbus_proxy.sh
    ```

### Extra steps for your first installation

1. Edit the config.yaml to fit your needs. The correct command for your installation is shown after the installation.

    ```bash
    nano /data/etc/modbus-proxy/config.yaml
    ```

2. Install the driver as a service. The correct command for your installation is shown after the installation.

    ```bash
    bash /data/etc/modbus-proxy/install.sh
    ```

    The daemon-tools should start this service automatically within seconds.

## Restart / Uninstall

Simply run the `restart` / `uninstall.sh` script:

```bash
bash /data/etc/modbus-proxy/uninstall.sh
```

## Debugging

The log can be shown via:

```bash
tail -n 100 -F /data/log/modbus-proxy/current | tai64nlocal
```

(adapt the `/modbus-proxy/` path depending on your installation)

The service status can be checked with svstat `svstat /service/modbus-proxy`

This will output somethink like `/service/modbus-proxy: up (pid 5845) 185 seconds`

If the script stops with the message `dbus.exceptions.NameExistsException: Bus name already exists: com.victronenergy.pvinverter.mqtt_pv"` it means that the service is still running or another service is using that bus name.

## Compatibility

This software was only tested on Venus OS 20250915, but should work on other versions too.

## Disclaimer

No warranties, use at your own risk. 