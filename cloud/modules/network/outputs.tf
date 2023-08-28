output "subnet_id_1" {
  value = oci_core_subnet.ewp_public[0].id
}

output "subnet_id_2" {
  value = oci_core_subnet.ewp_public[1].id
}

output "security_group" {
  value = oci_core_network_security_group.ewp_sg.id
}
