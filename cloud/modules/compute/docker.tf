resource "null_resource" "docker_config" {
  depends_on = [oci_core_instance.ewp_instance, oci_load_balancer_load_balancer.ewp_load_balancer]
  count      = 2

  provisioner "file" {
    source      = "./user_data.sh"
    destination = "/home/docker/install_docker.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = count.index == 0 ? var.subnet_ip_1 : var.subnet_ip_2
    }
  }

  provisioner "file" {
    source      = "./env.sh"
    destination = "/home/docker/env.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = count.index == 0 ? var.subnet_ip_1 : var.subnet_ip_2
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/docker/env.sh",
      "sudo bash /home/docker/install_docker.sh",
    ]

    connection {
      type = "ssh"
      user = "docker"
      host = count.index == 0 ? var.subnet_ip_1 : var.subnet_ip_2
    }
  }
}
