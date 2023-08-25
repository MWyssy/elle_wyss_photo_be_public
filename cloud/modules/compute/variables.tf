variable "subnet_id_1" {
  type = string
}

variable "subnet_id_2" {
  type = string
}

variable "subnet_ip_1" {
  type = string
}

variable "subnet_ip_2" {
  type = string
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
  default = 6
}

variable "ssh_public_key" {
  type = string
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
