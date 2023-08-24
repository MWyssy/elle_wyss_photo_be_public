resource "oci_objectstorage_bucket" "ewp_image_storage" {
  compartment_id = var.compartment_id
  name           = var.bucket_name
  namespace      = var.bucket_namespace

  access_type  = "ObjectRead"
  auto_tiering = "InfrequentAccess"

  freeform_tags = {
    "CreatedBy" = "Terraform"
    "UsedBy"    = "Elle Wyss Photography"
  }

}

locals {
  image_files = flatten([
    fileset("../assets/weddings", "**/")
  ])
}

resource "oci_objectstorage_object" "ewp_image_storage" {
  count = length(local.image_files)

  bucket       = oci_objectstorage_bucket.ewp_image_storage.name
  object       = "weddings/${local.image_files[count.index]}"
  source       = "../assets/weddings/${local.image_files[count.index]}"
  content_type = "image/jpeg"
  namespace    = var.bucket_namespace
}

