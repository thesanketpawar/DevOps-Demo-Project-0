resource "aws_instance" "servers" {
  for_each = local.instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = each.value.name
    }
  )
}
