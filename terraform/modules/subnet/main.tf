resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr
  availability_zone       = var.az
  map_public_ip_on_launch = var.public

  tags = {
    Name = var.name
  }
}

moved {
  from = aws_route_table_association.public[0]
  to   = aws_route_table_association.this
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = var.route_table_id
}
