output "subnet_id_1" {
  value = oci_core_subnet.ewp_public[0].id
}

output "subnet_id_2" {
  value = oci_core_subnet.ewp_public[1].id
}

output "subnet_ip_1" {
  value = oci_core_subnet.ewp_public[0].virtual_router_ip
}

output "subnet_ip_2" {
  value = oci_core_subnet.ewp_public[1].virtual_router_ip
}
