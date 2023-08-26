resource "null_resource" "docker_config" {
  depends_on = [oci_core_instance.ewp_instance]

  for_each = oci_core_instance.ewp_instance

  provisioner "file" {
    source      = "./user_data.sh"
    destination = "/home/docker/install_docker.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = each.value.public_ip
    }
  }

  provisioner "file" {
    source      = "./env.sh"
    destination = "/home/docker/env.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = each.value.public_ip
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
      host = each.value.public_ip
    }
  }
}
