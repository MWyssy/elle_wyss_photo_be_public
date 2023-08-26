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
    user_data           = data.cloudinit_config.ewp[each.key].rendered
    ssh_authorized_keys = file("/home/mike/software_dev/eli_website/elle_wyss_photo_be/cloud/id_rsa.pub")
  }
}


# resource "oci_load_balancer_load_balancer" "ewp_load_balancer" {
#   compartment_id = var.compartment
#   display_name   = var.lb_name
#   shape          = "flexible"
#   shape_details {
#     maximum_bandwidth_in_mbps = 10
#     minimum_bandwidth_in_mbps = 10
#   }

#   subnet_ids = var.subnet_ids
# }

# resource "oci_load_balancer_backend_set" "ewp_load_balancer_backend_set" {
#   name             = "lbBackendSet1"
#   load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   policy           = "ROUND_ROBIN"

#   health_checker {
#     port                = "80"
#     protocol            = "HTTP"
#     response_body_regex = ".*"
#     url_path            = "/health"
#   }

#   session_persistence_configuration {
#     cookie_name      = "lb-session1"
#     disable_fallback = true
#   }
# }

# resource "oci_load_balancer_backend" "ewp_load_balancer_backend" {
#   count = 2
#   #Required
#   backendset_name  = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
#   ip_address       = oci_core_instance.ewp_instance[count.index].public_ip
#   load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   port             = "80"
# }

# resource "oci_load_balancer_hostname" "lb_hostname" {
#   #Required
#   hostname         = "app.free.com"
#   load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   name             = var.lb_host_name
# }

# resource "oci_load_balancer_listener" "load_balancer_listener0" {
#   load_balancer_id         = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   name                     = "http"
#   default_backend_set_name = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
#   hostname_names           = [oci_load_balancer_hostname.lb_hostname.name]
#   port                     = 80
#   protocol                 = "HTTP"
#   rule_set_names           = [oci_load_balancer_rule_set.ewp_rule_set.name]

#   connection_configuration {
#     idle_timeout_in_seconds = "240"
#   }
# }

# resource "oci_load_balancer_rule_set" "ewp_rule_set" {
#   items {
#     action = "ADD_HTTP_REQUEST_HEADER"
#     header = "example_header_name"
#     value  = "example_header_value"
#   }

#   items {
#     action          = "CONTROL_ACCESS_USING_HTTP_METHODS"
#     allowed_methods = ["GET", "OPTIONS"]
#     status_code     = "405"
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   name             = "ewp_rule_set"
# }

resource "tls_private_key" "ewp_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ewp_self_signed_cert" {
  private_key_pem = tls_private_key.ewp_private_key.private_key_pem

  subject {
    organization = "Oracle"
    country      = "UK"
    locality     = "London"
    province     = "UK"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]

  is_ca_certificate = true
}

# resource "oci_load_balancer_certificate" "load_balancer_certificate" {
#   load_balancer_id   = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   ca_certificate     = tls_self_signed_cert.ewp_self_signed_cert.cert_pem
#   certificate_name   = "certificate1"
#   private_key        = tls_private_key.ewp_private_key.private_key_pem
#   public_certificate = tls_self_signed_cert.ewp_self_signed_cert.cert_pem

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "oci_load_balancer_listener" "ewp_load_balancer_listener" {
#   load_balancer_id         = oci_load_balancer_load_balancer.ewp_load_balancer.id
#   name                     = "https"
#   default_backend_set_name = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
#   port                     = 443
#   protocol                 = "HTTP"

#   ssl_configuration {
#     certificate_name        = oci_load_balancer_certificate.load_balancer_certificate.certificate_name
#     verify_peer_certificate = false
#   }
# }

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "id_rsa.pub"
  file_permission = "0600"
}

locals {
  compartment_id  = var.compartment
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
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
