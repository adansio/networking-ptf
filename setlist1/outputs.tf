output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = {
    db_priv_az1 = aws_subnet.db_priv_az1.id
    db_priv_az2 = aws_subnet.db_priv_az2.id
    app_priv_az1 = aws_subnet.app_priv_az1.id
    app_priv_az2 = aws_subnet.app_priv_az2.id
    fe_priv_az1 = aws_subnet.fe_priv_az1.id
    fe_priv_az2 = aws_subnet.fe_priv_az2.id
    dmz_pub_az1 = aws_subnet.dmz_pub_az1.id
    dmz_pub_az2 = aws_subnet.dmz_pub_az2.id
  }
}

output "security_groups" {
  value = {
    db_sg  = aws_security_group.db_sg.id
    app_sg = aws_security_group.app_sg.id
    fe_sg = aws_security_group.fe_sg.id
    dmz_sg = aws_security_group.dmz_sg.id
  }
}
