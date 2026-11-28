variable "vpc_id" { type = string }
variable "cidr" { type = string }
variable "az" { type = string }
variable "name" { type = string }

variable "public" {
  type    = bool
  default = false
}

variable "route_table_id" {
  type = string
}
