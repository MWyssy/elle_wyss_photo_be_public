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

resource "oci_core_subnet" "ewp_public" {
  count = 2

  cidr_block     = "10.0.${count.index + 1}.0/24"
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false

  dns_label = "${var.subnet_dns_label}${count.index}"

  route_table_id = module.vcn.ig_route_id

  freeform_tags = {
    "CreatedBy" = "Terraform",
    "UsedBy"    = "Elle Wyss Photography"
  }

}



