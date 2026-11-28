resource "aws_ebs_volume" "postgres" {
  availability_zone = module.subnet_isolated.availability_zone
  encrypted         = true
  size              = var.db_volume_size
  type              = "gp3"

  tags = {
    Name = "kubeadm-postgres-data"
  }
}

resource "aws_volume_attachment" "postgres" {
  device_name = "/dev/sdf"
  instance_id = module.db_worker.id
  volume_id   = aws_ebs_volume.postgres.id
}
