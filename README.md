# Manage Android STB Scripts

## Overview
The Manage Android STB Scripts are designed to facilitate the management of Android devices on a network. These scripts provide a convenient way to perform various administrative tasks, making it easier to control and monitor multiple devices from a central point.

## Key Features
- **Device Discovery**: Automatically detects Android devices connected to the network.
- **Remote Control**: Execute commands on Android devices remotely.
- **Monitoring**: Gather and display system information from Android devices.
- **Batch Operations**: Perform actions on multiple devices simultaneously.

## Usage Instructions
1. Clone the repository to your local machine.
2. Ensure that your Android devices are connected to the same network.
3. Execute the scripts using the command line interface.

## Example Commands
- To discover devices on the network:
  ```bash
  ./discover_devices.sh
  ```

- To execute a command on all connected device:
  ```bash
  ./remote_control.sh <command>
  ```

- To monitor device status:
  ```bash
  ./monitor_device.sh <device_ip>
  ```

For more detailed instructions, refer to the individual script documentation.
