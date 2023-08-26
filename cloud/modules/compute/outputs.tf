output "ads" {
  value = data.oci_identity_availability_domains.ad.availability_domains
}

output "ssh-with-docker-user" {
  value = join(
    "\n",
    [for i in oci_core_instance.ewp_instance :
      format(
        "ssh -l docker -p 22 -i %s # %s",
        i.public_ip,
        i.display_name
      )
    ]
  )
}
