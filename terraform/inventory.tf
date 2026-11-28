resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [bastion]
    bastion ansible_host=${aws_eip.bastion.public_ip}

    [control_plane]
    control-plane ansible_host=${module.control_plane.private_ip}

    [public_workers]
    public-worker ansible_host=${module.public_worker.private_ip}

    [private_workers]
    worker-1 ansible_host=${module.worker_1.private_ip}
    worker-2 ansible_host=${module.worker_2.private_ip}

    [db_workers]
    db-worker ansible_host=${module.db_worker.private_ip} postgres_ebs_volume_id=${aws_ebs_volume.postgres.id}

    [workers:children]
    public_workers
    private_workers
    db_workers

    [k8s:children]
    control_plane
    workers

    [k8s:vars]
    ansible_user=ec2-user
    ansible_ssh_common_args='-o ProxyJump=ec2-user@${aws_eip.bastion.public_ip}'
  EOT

  depends_on = [aws_eip_association.bastion]
}
