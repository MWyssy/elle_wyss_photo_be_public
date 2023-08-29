module "vcn" {
  source         = "oracle-terraform-modules/vcn/oci"
  version        = "3.5.4"
  compartment_id = var.compartment_id

  vcn_name = var.vcn_name

  vcn_dns_label = var.vcn_dns_label

  vcn_cidrs                = ["10.0.0.0/16"]
  create_internet_gateway  = true
  create_nat_gateway       = true
  nat_gateway_display_name = var.ng_name


  freeform_tags = {
    "CreatedBy" = "Terraform",
    "UsedBy"    = "Elle Wyss Photography"
  }

}

resource "oci_core_security_list" "ewp_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "ewp_security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "${data.external.my_ip.result.MY_IP}/32"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "ewp_public" {
  count = 2

  cidr_block     = "10.0.${count.index + 1}.0/24"
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false

  dns_label = "${var.subnet_dns_label}${count.index}"

  route_table_id = module.vcn.ig_route_id

  security_list_ids = [oci_core_security_list.ewp_security_list.id]

  freeform_tags = {
    "CreatedBy" = "Terraform",
    "UsedBy"    = "Elle Wyss Photography"
  }

}

resource "oci_core_network_security_group" "ewp_sg" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = var.security_group_name

}

resource "oci_core_network_security_group_security_rule" "ingress_http" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "INGRESS"

  protocol = "6"
  source   = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "80"
      min = "80"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_https" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "INGRESS"

  protocol = "6"
  source   = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "INGRESS"

  protocol = "6"
  source   = "${data.external.my_ip.result.MY_IP}/32"
  tcp_options {
    destination_port_range {
      max = "22"
      min = "22"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_port" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "EGRESS"

  protocol    = "6"
  destination = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "5000"
      min = "5000"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_watchtower" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "EGRESS"

  protocol    = "6"
  destination = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "8080"
      min = "8080"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_internet" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "EGRESS"

  protocol    = "6"
  destination = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_api" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "INGRESS"

  protocol = "6"
  source   = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "5000"
      min = "5000"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_watchtower" {
  network_security_group_id = oci_core_network_security_group.ewp_sg.id
  direction                 = "INGRESS"

  protocol = "6"
  source   = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = "8080"
      min = "8080"
    }
  }
}
