module "object-storage" {
  source = "./modules/object-storage"

  bucket_name      = "ewp_image_store"
  bucket_namespace = "lr4poue3hwjl"
  compartment_id   = "ocid1.tenancy.oc1..aaaaaaaa7ir42cknj7xvbqc77vftjpvx7aavbueua4hzkuaur6wx7lyyvuxq"
}
