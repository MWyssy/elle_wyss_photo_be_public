resource "oci_core_instance" "ewp_instance" {
  count = 2

  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment
  display_name        = "${var.instance_name}_${count.index + 1}"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = count.index == 0 ? var.subnet_id_1 : var.subnet_id_2
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.instance_name}_${count.index + 1}"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.ewp_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = filebase64("${path.module}/user_data.sh")
  }
}


resource "oci_load_balancer_load_balancer" "ewp_load_balancer" {
  compartment_id = var.compartment
  display_name   = var.lb_name
  shape          = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }

  subnet_ids = [
    var.subnet_id_1,
    var.subnet_id_2
  ]
}

resource "oci_load_balancer_backend_set" "ewp_load_balancer_backend_set" {
  name             = "lbBackendSet1"
  load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/health"
  }

  session_persistence_configuration {
    cookie_name      = "lb-session1"
    disable_fallback = true
  }
}

resource "oci_load_balancer_backend" "ewp_load_balancer_backend" {
  count = 2
  #Required
  backendset_name  = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
  ip_address       = oci_core_instance.ewp_instance[count.index].public_ip
  load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
  port             = "80"
}

resource "oci_load_balancer_hostname" "lb_hostname" {
  #Required
  hostname         = "app.free.com"
  load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
  name             = var.lb_host_name
}

resource "oci_load_balancer_listener" "load_balancer_listener0" {
  load_balancer_id         = oci_load_balancer_load_balancer.ewp_load_balancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
  hostname_names           = [oci_load_balancer_hostname.lb_hostname.name]
  port                     = 80
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.ewp_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = "240"
  }
}

resource "oci_load_balancer_rule_set" "ewp_rule_set" {
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "example_header_name"
    value  = "example_header_value"
  }

  items {
    action          = "CONTROL_ACCESS_USING_HTTP_METHODS"
    allowed_methods = ["GET", "OPTIONS"]
    status_code     = "405"
  }

  load_balancer_id = oci_load_balancer_load_balancer.ewp_load_balancer.id
  name             = "ewp_rule_set"
}

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

resource "oci_load_balancer_certificate" "load_balancer_certificate" {
  load_balancer_id   = oci_load_balancer_load_balancer.ewp_load_balancer.id
  ca_certificate     = tls_self_signed_cert.ewp_self_signed_cert.cert_pem
  certificate_name   = "certificate1"
  private_key        = tls_private_key.ewp_private_key.private_key_pem
  public_certificate = tls_self_signed_cert.ewp_self_signed_cert.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_listener" "ewp_load_balancer_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.ewp_load_balancer.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.ewp_load_balancer_backend_set.name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.load_balancer_certificate.certificate_name
    verify_peer_certificate = false
  }
}
