variable "ssh_allowed_cidr" {
  description = "Public IPv4 address allowed to SSH to the bastion, in /32 format."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "Enter a valid IPv4 address in /32 format."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the instance region."
  type        = string
}
