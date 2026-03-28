#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVICE_NAME=$(basename $SCRIPT_DIR)

echo
echo "Restarting $SERVICE_NAME..."

pid=$(pgrep -f "$SCRIPT_DIR/modbus-proxy")
if [ -n "$pid" ]; then
    svc -t /service/$SERVICE_NAME
    echo "done."
else
    echo "driver is not running!"
fi

echo