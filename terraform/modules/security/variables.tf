variable "vpc_id" { type = string }
variable "ssh_allowed_cidr" { type = string }

variable "team_ssh_allowed_cidrs" {
  type    = set(string)
  default = []
}
