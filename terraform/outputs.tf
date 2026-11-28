output "vpc_id" {
  value = module.vpc.id
}

output "bastion_public_ip" {
  value = aws_eip.bastion.public_ip
}

output "public_worker_public_ip" {
  value = aws_eip.public_worker.public_ip
}

output "public_worker_private_ip" {
  value = module.public_worker.private_ip
}

output "control_plane_private_ip" {
  value = module.control_plane.private_ip
}

output "worker_1_private_ip" {
  value = module.worker_1.private_ip
}

output "worker_2_private_ip" {
  value = module.worker_2.private_ip
}

output "db_worker_private_ip" {
  value = module.db_worker.private_ip
}

output "db_volume_id" {
  value = aws_ebs_volume.postgres.id
}
