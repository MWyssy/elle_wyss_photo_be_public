output "subnet_one_id" {
  value = oci_core_subnet.ewp_public[0].id
}

output "subnet_two_id" {
  value = oci_core_subnet.ewp_public[1].id
}

