# ecom-infra

Terraform provisions the isolated `db-worker` in `subnet-isolated` and attaches an encrypted EBS data volume. The Ansible inventory generator includes that worker and volume ID; the first play mounts the volume at `/mnt/postgres-data`, then the standard cluster setup joins and labels the node `marketly.io/role=database`.

The isolated subnet has no internet route. `db_ami_id` must refer to a prepared AMI containing containerd, kubelet, kubeadm, kubectl, Kubernetes prerequisites, filesystem tools, and the `postgres:17.12-alpine` image. The Helm local PV in `ecom-deploy` uses that mounted EBS path and requires its capacity to match `db_volume_size`.

The `Provision Infrastructure and Kubernetes` workflow plans Terraform and, when `execute` is enabled, applies the plan, generates inventory, and runs Ansible in the same job. Add the matching EC2 private key as the `ANSIBLE_SSH_PRIVATE_KEY` secret in the `infra-dev` environment. The bastion security group only permits SSH from the configured `SSH_ALLOWED_CIDR` and `TEAM_SSH_ALLOWED_CIDRS`; the GitHub-hosted runner must have network access through an approved, stable egress IP or the Ansible SSH steps will time out. The separate Apply and Configure Kubernetes workflows remain available.
