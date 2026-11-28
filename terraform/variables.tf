variable "ssh_allowed_cidr" {
  description = "Public IPv4 address allowed to SSH to the bastion, in /32 format."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "Enter a valid IPv4 address in /32 format."
  }
}

variable "team_ssh_allowed_cidrs" {
  description = "Additional public IPv4 addresses allowed to SSH to the bastion, in /32 format."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for cidr in var.team_ssh_allowed_cidrs :
      can(cidrnetmask(cidr)) && try(endswith(cidr, "/32"), false)
    ])
    error_message = "Each team SSH CIDR must be a valid IPv4 address in /32 format."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the instance region."
  type        = string
}

variable "db_ami_id" {
  description = "ID of a prepared x86_64 Amazon Linux 2023 AMI with preinstalled Kubernetes packages, PostgreSQL image, and boot-time EBS formatting/mount setup for /mnt/postgres-data."
  type        = string

  validation {
    condition     = can(regex("^ami-([0-9a-f]{8}|[0-9a-f]{17})$", var.db_ami_id))
    error_message = "Enter a valid AMI ID for the isolated database worker."
  }
}

variable "db_volume_size" {
  description = "Size in GiB of the separate PostgreSQL data volume."
  type        = number
  default     = 10

  validation {
    condition     = var.db_volume_size >= 1 && var.db_volume_size <= 65536 && floor(var.db_volume_size) == var.db_volume_size
    error_message = "Enter an integer disk size between 1 and 65536 GiB."
  }
}
