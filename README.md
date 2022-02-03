# Node Exporter Lua - Additional Asus Exporters

This repo is for additional prometheus node exporter collectors for ASUS RT-AC58U routers.
This may also support similar ASUS routers (but has not been tested on anything other than the RT-AC58U).

You must have the `prometheus-node-exporter-lua` package installed via `opkg` or LuCI and have it configured and working.

All of the files in repo should be copied to `/usr/lib/lua/prometheus-collectors` folder.
Once they have been copied over, you will need to restart Node Exporter:

```sh
/etc/init.d/prometheus-node-exporter-lua restart
```

## Included Exporters

*If the included exporter metrics are named the same as the official Node Exporter then assume they will work in the exact same way.*

### Hardware Temperature Monitoring (`hwmon.lua`)

Exposes the following metrics:

| Metric                       | Description                                                                                                            |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| node_hwmon_chip_names        | The hardware monitoring chip names.                                                                                    |
| node_hwmon_temp_celsius      | The temperature in celsius.                                                                                            |
| node_hwmon_temp_sensor_label | The labels for the temperature sensors.                                                                                |
| node_hwmon_temp_sensor_iface | Gets the interface the sensor is associated with. ASUS RT-AC58U temperature sensors don't have distinguishable labels. |
