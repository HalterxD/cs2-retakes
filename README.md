# CS2 Retakes Installer

Simple installer for a Counter-Strike 2 retakes server using LinuxGSM, Metamod, and CounterStrikeSharp.

The script installs the server, dependencies, and plugins automatically.

## Install

Run the installer with:

```
bash <(curl -fsSL https://raw.githubusercontent.com/swastik-satpathy/cs2-server-manager/main/cs2-retakes-installer/install.sh)
```

Or clone the repository and run locally:

```
git clone https://github.com/swastik-satpathy/cs2-server-manager.git
cd cs2-server-manager/cs2-retakes-installer
chmod +x install.sh
./install.sh
```

## What it installs

* LinuxGSM
* Counter-Strike 2 server
* Metamod
* CounterStrikeSharp
* Plugins defined in `plugins.json`

## Plugins

Plugins are defined in `plugins.json`.

Example:

```
{
  "retakes": {
    "url": "https://example.com/plugin.zip"
  }
}
```

Edit this file to add or change plugins and rerun the installer.

## Server location

Server files are installed in:

```
/home/cs2server/serverfiles
```

## Managing the server

Switch to the server user:

```
su - cs2server
```

Start the server:

```
./cs2server start
```

Restart the server:

```
./cs2server restart
```

View console:

```
./cs2server console
```

## Notes

Running the installer again will repair an existing installation and skip components that are already installed.
