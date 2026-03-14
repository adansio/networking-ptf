provider "aws" {
  region = "ap-southeast-2"  
}

#resource "aws_vpc" "hybrid-conn-vpc" {
#  cidr_block = "10.0.0.0/16"
#  tags = { Name = "hybrid-conn-vpc" }
#}

# Virtual Private Gateway 
resource "aws_vpn_gateway" "vgw-to-onprem" {
  vpc_id = "vpc-0784211c5bd7fc74f"  
  tags = { Name = "vgw-onprem" }
}

# Customer Gateway 
resource "aws_customer_gateway" "customer-gw-onprem" {
  bgp_asn    = 65000
  ip_address = "1.2.3.4"
  type       = "ipsec.1"
  tags = { Name = "fw-onprem" }
}

# Site-to-Site VPN 
resource "aws_vpn_connection" "vpn-onprem" {
  customer_gateway_id = aws_customer_gateway.customer-gw-onprem.id
  vpn_gateway_id      = aws_vpn_gateway.vgw-to-onprem.id
  type                = "ipsec.1"
  static_routes_only  = false
  tags = { Name = "vpn-onprem" }
}
