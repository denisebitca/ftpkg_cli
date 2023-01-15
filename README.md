<p align="center">
  <img alt="ftpkg_cli logo" src="ftpkg_cli.png" width="250">
</p>
<h2 align="center">
  Bash terminal utility for installing curated Flatpak packages by the 42 Paris team on 42 Paris dumps
  <p>
    <img alt="license badge" src="https://img.shields.io/badge/license-GPLv3_or_later-green">
    <img alt="norminet badge" src="https://img.shields.io/badge/norminet-included-blue">
  </p>
</h2>

### Why this?

I have a startup script that automatically sets up dumps whenever I log into them - and that includes installing packages I use automatically. I'd like to make it easy for everyone to do the same thing. To be honest, most people just keep binaries around, but if we have a whole package manager at our hands, might as well use it!

### How do I use it?

Git clone the latest release and run it like this:
```
./ftpkg_cli
```

Here are all the options you can use:

```
$ ./ftpkg_cli
ftpkg_cli v0.1 - terminal utility for installing curated Flatpak packages by the 42 Paris team on 42 Paris dumps
Copyright (C) 2023 Denise BITCA
This program comes with ABSOLUTELY NO WARRANTY; This is free software, and you are welcome to redistribute it under certain conditions; see LICENSE file for more.

Usage: ftpkg_cli [OPTION]...
Formatting options (combining possible):
        --no-header                     Hide license header (default: false)
        --no-color                      Disable color output (default: false)
        --script-friendly               Stable formatting for usage in scripts (default: false)
General options (only one at a time):
        -q, --query                     Get list of available packages
        -i, --install <package_name>    Install package
        -u, --uninstall <package_name>  Uninstall package
Query options (for -q, --query):
        --installed                     Filter packages that are not installed (default: false)
Install/uninstall options (for -u, -i, --install, --uninstall):
        --password <password>           Password for the ftpkg server (default: none)
```



### What password? ftpkg server? Huh?

The program automatically gets the password for you when running operations that require the password - don't think about it.

If you're on Mac, it might be faster for you to keep the password somewhere and run the command with the password.

To obtain said password:
```bash
docker compose -f ./docker/docker-compose.yaml build
docker compose -f ./docker/docker-compose.yaml run get_ftpkg_password
```

To use the password:
```
./ftpkg_cli --install <package name> --password <password>
```

### Are we allowed to use this on dumps?

I'm not sure - part of the process is literally reverse engineering an executable in order to obtain a hardcoded password. Guess we'll find out!

**___NOTE: DO NOT POST THE PASSWORD IN ISSUES OR LEAVE IT IN PULL REQUESTS___**

### How does it work?

ftpkg is composed of a client (the executable you run) and a server communicating via HTTP over TCP.

For example, here is how the ftpkg executable gets the list of packages that you can install/uninstall/update.

```mermaid
sequenceDiagram
  Client->>+Server: GET /status
  Server->>-Client: {json file}
```

A package is usually formatted like this:

```json
{
  "name": "Android Studio",
  "package_name": "com.google.AndroidStudio",
  "category": "Development",
  "icon": "<app icon in base64>",
  "version": "2021.3.1.17",
  "description": "Integrated development environment for Google's Android platform",
  "state": "0"
}
```

Note: ``"state": "0"`` means "this package is not installed" and ``"state": "1"`` means "this package is installed".

Here is an example of what installing a program looks like:

```mermaid
sequenceDiagram
  Client->>+Server: GET /install/<password>/com.google.AndroidStudio
  Server->>-Client: OK
```

The expected password is hardcoded inside the ftpkg executable.

### How do I contribute?

Feel free to drop an issue or a pull request, especially if you like using the Mac dumps (because I haven't tested this on them).
If your campus uses ftpkg and this doesn't work, you are more than encouraged to drop an issue.
