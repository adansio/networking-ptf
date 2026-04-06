variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_name" {
  type    = string
  default = "setlist_1"
}

# IDs de zonas de disponibilidad 
variable "az1" {
  type = string
  default = "ap-southeast-2a"
  description = "ap-southeast-2a"
}

variable "az2" {
  type = string
  default = "ap-southeast-2b"
  description = "ap-southeast-2b"
}

# Prefijos
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}
