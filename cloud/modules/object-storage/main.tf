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

resource "oci_objectstorage_object" "ewp_image_storage" {
  depends_on = [oci_objectstorage_bucket.ewp_image_storage]

  dynamic "object" {
    for_each  = fileset("${path.module}/../assets/weddings", "**/*")
    bucket    = oci_objectstorage_bucket.ewp_image_storage.name
    namespace = var.bucket_namespace

    source = "${path.module}/../assets/weddings/${each.value}"
    object = "weddings/${each.key}"

  }

}

# resource "oci_objectstorage_object" "ewp_image_storage" {
#   depends_on = [oci_objectstorage_bucket.ewp_image_storage]

#   bucket       = oci_objectstorage_bucket.ewp_image_storage.name
#   namespace    = var.bucket_namespace
#   source       = "../assets/weddings/Tom and Rebecca/Cover/cover.jpg"
#   object       = "weddings/Tom and Rebecca/Cover/cover.jpg"
#   content_type = "image/jpg"
# }
