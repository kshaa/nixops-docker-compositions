# Hello World with NixOps, systemd & docker-compose 
Nix is very powerful at configuring systems.  
Docker has huge community with a lot of software **ready-to-go**.  

So I want to use NixOps to manage docker compositions.  
This repository is an implementation of that desire.  
Slightly rough around the edges, but quite neat!  
Rough and uncertain edges:
- Will changing the helloworld derivation update the helloworld service when deploying?  
- Does restarting `helloworld.service` first restart and wait for `helloworldPrepare.service`?  
- Does restarting `helloworldPrepare.service` restart `helloworld.service`?  

Helpful resources while creating this repo:
- [grafted-in/nixops-manager](https://github.com/grafted-in/nixops-manager/)  
- [grafted-in/wordpress-nginx-nix](https://github.com/grafted-in/wordpress-nginx-nix/)  
- [NixOS/nixpkgs::nixos/modules/services/networking/unifi.nix](https://github.com/NixOS/nixpkgs/blob/7b8a7cee78468919b98cc4c8694d84165f28ef68/nixos/modules/services/networking/unifi.nix)   

For more info on anything you see here - comb through those repos.  

# Usage
```bash
$ deploy/manage development create '<server/logical.vbox.nix>' '<server/physical.vbox.nix>'
[...]

$ deploy/manage development info
[...]
+----------+-----------------+------------+------------------------------------------------------+--------------+
| Name     |      Status     | Type       | Resource Id                                          | IP address   |
+----------+-----------------+------------+------------------------------------------------------+--------------+
| untitled | Up / Up-to-date | virtualbox | nixops-4387c0c7-a638-11e9-a85a-0242c94800a9-untitled | 192.168.56.6 |
+----------+-----------------+------------+------------------------------------------------------+--------------+

$ curl http://192.168.56.6/ -H "Host: helloworld.local"
Hello Sir
```

# Fun facts
## Dockerized project
There's a very typical docker-composition in [./modules/helloworld](./modules/helloworld). 
The `docker-compose.yaml` there has a service with the following "NodeJS Hello World" image - [adam-golab/docker-hello-world](https://github.com/adam-golab/docker-hello-world).  

## NixOS configuration
There are also some Nix & NixOS specific files for packaging that dockerized project.  
[./modules/helloworld](./modules/helloworld) contains those `.nix` files.  

### Nix files
[./modules/helloworld/app.nix](./modules/helloworld/app.nix) instructs how to build & package project files (i.e. declares a "Nix derivation").   

[./modules/helloworld/default.nix](./modules/helloworld/default.nix) a customizable module for deploying the project on NixOS.  
The module does the following things.  
- Using configurable options generates a `.env` file for `docker-compose.yaml` customization.  
- Using configurable options generates a `.env.helloworld` file for dockerized `helloworld` service.  
- Declares a configurable Linux user "helloworld" & group "helloworld", which are used by systemd units.
- Declares a systemd unit for preparing the project environment
    - Cleans up previous deployments at `/var/www/helloworld`  
    - Creates `/var/www/helloworld`  
    - Copies the packaged project code  
    - Copies the `.env` and `.env.helloworld`   
    - Optionally symlinks a "persistent" directory in the working directory if one is provided
- Declares a systemd unit for for running the project  
    - Sets the working directory as `/var/www/helloworld`  
    - Runs `docker-compose up` to start the docker composition  
    - ^ That's not how one should deploy docker containers in production, but that's fine for me  

In the end this NixOS module is deployed to a VirtualBox machine with NixOps as per [# Usage](#usage).  