output "subnet_id" {
  value = aws_subnet.ctf_subnet.id
}

output "sg_id" {
  value = aws_security_group.ctf_sg.id
}