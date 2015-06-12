RDesktop GUI Interface For Linux
=

Description
-
The RDesktop GUI Script is a simple Bash script which calls zenity and rdesktop and enables the management of RDP connections from the Linux Operating System. The script was origonally written on Linux Mint 17.1 (and by extension Ubuntu), however, it may work on other Linux based distributions.

> **Some features include:**

> - Specifying global prefences for all connections
> - Specifying preferences for all connections in a single folder (grouping)
> - Sharing credentials with multiple connections
> - Script, Credentials, and Server configs can all be in different locations

Documentation on variables that can be defined are located in the provided configuration files.

I am by no means a scripting genius, but this works for me. If anybody has any suggestions to make improvements, let me know and I'll add them for the benefit of others.

How It Works
-

- When the script is executed, it will use pre-set directories to look for credentials and server connections.

> -  These can be overridden by defining an 'override.conf' in the same folder as the script.

- The user selects the server config file to load if it wasn't specified on the command line (e.g. script was called directly from file manager)
- Global settings are then loaded from the file 'defaults.conf' in the script folder
- Group settings are loaded from the file 'defaults.conf' in the server config folder
- The script finally loads the server config file settings
- RDesktop is executed with the settings defined

Extending The Solution
-
The script was written with the purpose of associating an extension to the server config files (e.g. *.rdp) within the file manager under the Windows Manager (e.g. nemo/nautalus). This allows for the creation of a folder strcture with RDP connections that can be managed and groupped in a similar fashion to Microsofts Remote Desktop Connection Manager in Windows.

This allows for a full GUIish interface with little/no GUI that everybody should be able to use once the config files are configured.
