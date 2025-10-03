variable "vpc_id" {
  type = string
}


variable "image_id" {
  type = string

}
variable "instance_type" {
  type = string

}
variable "key_name" {
  type = string
}
variable "apci_jupiter_public_subnet_az_1a" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "apci_jupiter_private_subnet_az_1a" {
  type = string
}
variable "apci_jupiter_private_subnet_az_1c" {
  type = string
}