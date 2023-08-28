variable "subnet_id_1" {
  type = string
}

variable "subnet_id_2" {
  type = string
}

variable "subnet_ids" {

}

variable "compartment" {
  type = string
}

variable "instance_shape" {
  type = string
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_shape_config_memory_in_gbs" {
  default = 1
}

variable "lb_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "lb_host_name" {
  type = string
}

variable "tenancy_ocid" {
  type = string
}

variable "how_many_nodes" {

}

variable "security_group" {

}

variable "lb_bes" {

}

variable "lb_listener" {

}
