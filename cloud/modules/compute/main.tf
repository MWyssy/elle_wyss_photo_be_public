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
    source_id   = data.oci_core_images.ewp_images.images[0].id
    source_type = "image"
  }
  create_vnic_details {
    subnet_id        = each.value.subnet_id
    private_ip       = each.value.ip_address
    nsg_ids          = ["${var.security_group}"]
    assign_public_ip = false
  }

  metadata = {
    user_data           = filebase64("${path.module}/user_data.sh")
    ssh_authorized_keys = file("/home/mike/.ssh/id_rsa.pub")
  }

  # freeform_tags = {
  #   "public_ip" = oci_core_public_ip.ewp_ip[each.key].ip_address
  # }

}

resource "oci_core_public_ip" "ewp_ip" {
  depends_on = [oci_core_instance.ewp_instance]
  for_each   = local.nodes

  compartment_id = var.compartment
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.ewp[0].private_ips[each.key].id
}


# resource "oci_load_balancer_certificate" "ssl_certificate" {
#   certificate_name = "ewp_ssl_cert"
#   load_balancer_id = oci_load_balancer_load_balancer.ewp_lb.id

# }

# resource "oci_load_balancer_load_balancer" "ewp_lb" {
#   compartment_id = var.compartment
#   display_name   = var.lb_name
#   subnet_ids     = [var.subnet_id_1]

#   is_private = false
#   ip_mode    = "IPV4"

#   network_security_group_ids = [var.security_group]

#   shape = "flexible"
#   shape_details {
#     maximum_bandwidth_in_mbps = "10"
#     minimum_bandwidth_in_mbps = "10"
#   }
# }

# resource "oci_load_balancer_backend_set" "ewp_lb" {
#   health_checker {
#     protocol            = "HTTP"
#     port                = "5000"
#     url_path            = "/health"
#     response_body_regex = "Server Running!"
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.ewp_lb.id
#   name             = var.lb_bes
#   policy           = "LEAST_CONNECTIONS"
# }


# resource "oci_load_balancer_listener" "ewp_lb" {
#   default_backend_set_name = oci_load_balancer_backend_set.ewp_lb.name
#   load_balancer_id         = oci_load_balancer_load_balancer.ewp_lb.id
#   name                     = var.lb_listener
#   port                     = "80"
#   protocol                 = "HTTP"
#   hostname_names           = [var.lb_host_name]

# }


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
