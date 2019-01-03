# This config file helps in creating a VM [Centos] on AHV cluster, install NGINX and it creates an AD object and DNS entry for VM

* Install terraform - Its pretty easy method. Follow below links.
https://learn.hashicorp.com/terraform/getting-started/install.html
https://www.terraform.io/downloads.html
* Clone repository to your terraform machine
* Move to the repository
    cd "repo path"
* As i have already compiled the providers and placed in the git, you can directly initialize terraform after making necessary changes as per you infra in the main.tf file. [This works perfectly in Centos 7]

Pre-requisites:

* A network with IPAM - Only assigned IPs will work 
* Centos referance image
    * Make sure to set "ONBOOT=yes" in the network "ifcfg-eth0" file
* AD admin credentials




