resource "oci_core_instance" "ewp_instance" {
  for_each            = local.nodes
  display_name        = each.value.node_name
  availability_domain = data.template_file.ad_names[each.key].rendered
  compartment_id      = var.compartment
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
    ocpus         = var.instance_ocpus
  }
  source_details {
    source_id               = data.oci_core_images.ewp_images.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = 30000
  }
  create_vnic_details {
    subnet_id  = each.value.subnet_id
    private_ip = each.value.ip_address
  }
  metadata = {
    user_data           = filebase64("./user_data.sh")
    ssh_authorized_keys = file("/home/mike/software_dev/eli_website/elle_wyss_photo_be/cloud/id_rsa.pub")
  }
}

locals {
  nodes = {
    for i in range(var.how_many_nodes) :
    i => {
      node_name  = "${var.instance_name}_${i + 1}"
      ip_address = format("10.0.1.%d", 10 + (i + 1))
      subnet_id  = var.subnet_ids[i]
    }
  }
}
