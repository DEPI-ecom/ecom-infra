output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "nodes_sg_id" {
  value = aws_security_group.nodes.id
}

output "control_plane_sg_id" {
  value = aws_security_group.control_plane.id
}

output "public_ingress_sg_id" {
  value = aws_security_group.public_ingress.id
}
