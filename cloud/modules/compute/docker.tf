resource "null_resource" "docker_config" {
  count = 2

  provisioner "file" {
    source      = "./user_data.sh"
    destination = "/home/docker/install_docker.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = var.subnet_id[count.index + 1].id
    }
  }

  provisioner "file" {
    source      = "./env.sh"
    destination = "/home/docker/env.sh"

    connection {
      type = "ssh"
      user = "docker"
      host = var.subnet_id[count.index + 1].id
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
      host = var.subnet_id[count.index + 1].id
    }
  }
}
