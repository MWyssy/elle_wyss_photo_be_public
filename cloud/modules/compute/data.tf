data "oci_core_images" "ewp_images" {
  compartment_id           = var.compartment
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count    = 3
  template = lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")
}
