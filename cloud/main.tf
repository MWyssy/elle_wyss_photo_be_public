module "object-storage" {
  source = "./modules/object-storage"

  bucket_name      = "ewp_image_store"
  bucket_namespace = "lr4poue3hwjl"
  compartment_id   = var.compartment
}

module "network" {
  source = "./modules/network"

  ng_name        = "ewp_nat_gateway"
  vcn_name       = "ewp_vcn"
  compartment_id = var.compartment

  vcn_dns_label    = "apivcn"
  subnet_dns_label = "ewp"
}

module "compute" {
  source         = "./modules/compute"
  depends_on     = [module.network]
  how_many_nodes = 2

  subnet_id_1    = module.network.subnet_id_1
  subnet_id_2    = module.network.subnet_id_2
  subnet_ids     = [module.network.subnet_id_1, module.network.subnet_id_2]
  compartment    = var.compartment
  instance_shape = "VM.Standard.A1.Flex"
  lb_name        = "ewp_lb"
  instance_name  = "ewp_instance"
  lb_host_name   = "ewp-api"
  tenancy_ocid   = var.tenancy_ocid
}
