#======================= Provider Configuration================================
#Configure Nutanix Provider [Prism Central / Prism Element]

provider "nutanix" {
  username = "username"
  password = "password"
  endpoint = "Virtual IP"
  insecure = true
  port     = 9440
}
#----------------
#configure AD Provider for creating computer object
provider "ad" {
  domain         = "domain.local"
  user           = "username"
  password       = "password"
  ip             = "AD IP/FQDN"
}
#Refer below
#https://github.com/GSLabDev/terraform-provider-ad

#----------------

#create a DNS record

provider "windows-dns" {
        server_name = "AD IP/FQDN"
        username    = "<username>"
        password    = "<password>"
}

#Refer below
#https://github.com/elliottsam/terraform-provider-windows-dns
#----------------
#===============================================================================

#Define Static IP for VM
variable "ip" {
  type    = "string"
  default = "IP_for_VM"
}

#Define image for VM
data "nutanix_image" "centos" {
    image_id = "2b4b5942-2c0e-45eb-b17e-a10b8479c824"
}

#------------------Create VM--------------------------------
resource "nutanix_virtual_machine" "sandeep_vm" {
 name = "sandeep_vm_nginx"
 description = "sandeep"
 num_vcpus_per_socket = 2
 num_sockets          = 1
 memory_size_mib      = 4096
 nic_list = [
   {
     subnet_reference = {
       kind = "subnet"
       uuid = "aee9fd0b-41e1-4be2-9d9e-a501b37e2fad"
     }

     ip_endpoint_list = {
      ip   = "${var.ip}"
      type = "ASSIGNED"
     }
   }
 ]

  disk_list = [{
    data_source_reference = [{
      kind = "image"      
      uuid = "${data.nutanix_image.centos.image_id}"
    }]

    device_properties = [{
      device_type = "DISK"
    }]
    disk_size_mib = 50000
  }]

provisioner "remote-exec" {
connection {
    type     = "ssh"
    host     = "${var.ip}"
    user     = "root"
    password = "nutanix/4u"
  }

    inline = [
      "sudo yum install epel-release -y",
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      #run the following commands to allow HTTP and HTTPS traffic
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --permanent --zone=public --add-service=https",
      "sudo firewall-cmd --reload",
    ]
  }
}

#-------------Creates AD Computer Object,DNS records-----------s
resource "ad_computer" "test" {
  domain        = "xcloud.local"
  computer_name = "${nutanix_virtual_machine.sandeep_vm.name}"
  description   = "terraform sample server"

depends_on = ["nutanix_virtual_machine.sandeep_vm"]
}


#create a DNS record
resource "windows-dns_record" "dnsentry" {
        domain = "domain.local"
        name   = "${nutanix_virtual_machine.sandeep_vm.name}"
        type   = "A"
        value  = "${var.ip}"
        ttl    = "10m0s"
depends_on = ["nutanix_virtual_machine.sandeep_vm"]
}
