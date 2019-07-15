# NixOps-deployed web hello-world docker composition 
Nix is very powerful at configuring systems.  
Docker has huge community with a lot of software **ready-to-go**.  

So I want to use NixOps to manage docker compositions.  
This repository is an implementation of that desire.  
Slightly rough around the edges, but quite neat!
Rough and uncertain edges:
- Will changing the helloworld derivation update the helloworld service when deploying?  
- Does restarting helloworld.service first restart and wait for helloworldPrepare.service?  
- Does restarting helloworldPrepare.service restart helloworld.service?  

Helpful resources while creating this repo:
- [grafted-in/nixops-manager](https://github.com/grafted-in/nixops-manager/)  
- [grafted-in/wordpress-nginx-nix](https://github.com/grafted-in/wordpress-nginx-nix/)  
- [NixOS/nixpkgs::nixos/modules/services/networking/unifi.nix](https://github.com/NixOS/nixpkgs/blob/7b8a7cee78468919b98cc4c8694d84165f28ef68/nixos/modules/services/networking/unifi.nix) - 
    Elegant systemd bind mount creation.

For instructions on anything you see here - comb through those repos.  

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