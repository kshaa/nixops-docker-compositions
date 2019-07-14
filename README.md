# NixOps-deployed web hello-world docker composition 
Nix is very powerful at configuring systems.  
Docker has huge community with a lot of software **ready-to-go**.  

So I want to use NixOps to manage docker compositions.  
This repository is an implementation of that desire.  

Heavy inspirations:
- [grafted-in/nixops-manager](https://github.com/grafted-in/nixops-manager/)  
- [grafted-in/wordpress-nginx-nix](https://github.com/grafted-in/wordpress-nginx-nix/)  

For instructions on anything you see here - comb through those repos.  

# Usage
```bash
$ deploy/manage development create '<server/logical.vbox.nix>' '<server/physical.vbox.nix>'
[...]

$ deploy/manage development info
[...]
+------------+-----------------+------------+--------------------------------------------------------+--------------+
| Name       |      Status     | Type       | Resource Id                                            | IP address   |
+------------+-----------------+------------+--------------------------------------------------------+--------------+
| untitled   | Up / Up-to-date | virtualbox | nixops-4387c0c7-a638-11e9-a85a-0242c94800a9-fuchsia    | 192.168.56.3 |
+------------+-----------------+------------+--------------------------------------------------------+--------------+

$ nc 192.168.56.3 80
GET / HTTP/1.0
Host: helloworld.local

HTTP/1.1 200 OK
Server: nginx
[...]

Hello World
```