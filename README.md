# ecom-infra

Terraform provisions the isolated `db-worker` in `subnet-isolated` and attaches an encrypted EBS data volume. The Ansible inventory generator includes that worker and volume ID; the first play mounts the volume at `/mnt/postgres-data`, then the standard cluster setup joins and labels the node `marketly.io/role=database`.

The isolated subnet has no internet route. `db_ami_id` must refer to a prepared AMI containing containerd, kubelet, kubeadm, kubectl, Kubernetes prerequisites, filesystem tools, and the `postgres:17.12-alpine` image. The Helm local PV in `ecom-deploy` uses that mounted EBS path and requires its capacity to match `db_volume_size`.
