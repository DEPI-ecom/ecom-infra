resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [bastion]
    bastion ansible_host=${module.bastion.public_ip}

    [control_plane]
    control_plane ansible_host=${module.control_plane.private_ip}

    [workers]
    worker_node_1 ansible_host=${module.worker_1.private_ip}
    worker_node_2 ansible_host=${module.worker_2.private_ip}

    [k8s:children]
    control_plane
    workers

    [k8s:vars]
    ansible_user=ec2-user
    ansible_ssh_common_args='-o ProxyJump=ec2-user@${module.bastion.public_ip}'

  EOT
}