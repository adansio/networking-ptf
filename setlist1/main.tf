# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway (para subnets públicas)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-igw" }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

# --- Subnets: DB-privateNet (10.10.10.0/23 -> two /24s) ---
resource "aws_subnet" "db_priv_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = var.az1
  tags = { Name = "DB-privNet-${var.az1}" }
}

resource "aws_subnet" "db_priv_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = var.az2
  tags = { Name = "DB-privNet-${var.az2}" }
}

# --- Subnets: App-privateNet (10.10.20.0/22 -> two /24s within that block) ---
resource "aws_subnet" "app_priv_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = var.az1
  tags = { Name = "App-privNet-${var.az1}" }
}

resource "aws_subnet" "app_priv_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = var.az2
  tags = { Name = "App-privNet-${var.az2}" }
}

# --- Subnets: FE-privateNet (10.10.32.0/22 -> two /24s within that block) ---
resource "aws_subnet" "fe_priv_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.32.0/24"
  availability_zone = var.az1
  tags = { Name = "fe-privNet-${var.az1}" }
}

resource "aws_subnet" "fe_priv_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.33.0/24"
  availability_zone = var.az2
  tags = { Name = "fe-privNet-${var.az2}" }
}

# --- Subnets: DMZ-PublicNet (10.10.40.0/23 -> two /24s) ---
resource "aws_subnet" "dmz_pub_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.40.0/24"
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = { Name = "dmz-pubNet-${var.az1}" }
}

resource "aws_subnet" "dmz_pub_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.41.0/24"
  availability_zone = var.az2
  map_public_ip_on_launch = true
  tags = { Name = "dmz-pubNet-${var.az2}" }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "dmz_pub_az1_assoc" {
  subnet_id      = aws_subnet.dmz_pub_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "dmz_pub_az2_assoc" {
  subnet_id      = aws_subnet.dmz_pub_az2.id
  route_table_id = aws_route_table.public.id
}

# --- NAT Gateway + Elastic IP 
resource "aws_eip" "nat_eip" {
  #vpc = true
  tags = { Name = "${var.vpc_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.dmz_pub_az1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "${var.vpc_name}-natgw-az1" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.vpc_name}-private-rt" }
}

# --- Asociacion de subnets privadas a RT
resource "aws_route_table_association" "fe_priv_az1_assoc" {
  subnet_id      = aws_subnet.fe_priv_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "fe_priv_az2_assoc" {
  subnet_id      = aws_subnet.fe_priv_az2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "app_priv_az1_assoc" {
  subnet_id      = aws_subnet.app_priv_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "app_priv_az2_assoc" {
  subnet_id      = aws_subnet.app_priv_az2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db_priv_az1_assoc" {
  subnet_id      = aws_subnet.db_priv_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db_priv_az2_assoc" {
  subnet_id      = aws_subnet.db_priv_az2.id
  route_table_id = aws_route_table.private.id
}
# --- NAT GW en plan LAB - habilitar un 2do NAT GW para HA en la otra AZ

# --- Security Groups ---

# SG para DB (solo accesible desde App-privateNet)
resource "aws_security_group" "db_sg" {
  name        = "${var.vpc_name}-sg-db"
  description = "Allow DB access only from App-privateNet CIDRs"
  vpc_id      = aws_vpc.this.id

  # Inbound: permitir solo desde App-privateNet CIDRs (las dos subnets)
  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.10.20.0/24", "10.10.21.0/24"]
    description = "Allow TCP from App-privateNet subnets"
  }

  # Ejemplo MySQL: from_port = 3306, to_port = 3306, protocol = "tcp"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = { Name = "${var.vpc_name}-sg-db" }
}

# SG para App (solo accesible desde Web-PublicNet)
resource "aws_security_group" "app_sg" {
  name        = "${var.vpc_name}-sg-app"
  description = "Allow app access only from Web-PublicNet CIDRs"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.10.32.0/24", "10.10.33.0/24"]
    description = "Allow TCP from Web-PublicNet subnets"
  }

  # Permitir que la App hable con la DB (si las aplicaciones en App-privateNet necesitan conectarse a BD,
  # típicamente se permite outbound hacia DB; el SG de DB ya permite inbound desde App subnets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = { Name = "${var.vpc_name}-sg-app" }
}

# SG para FE (solo accesible desde DMZ-PublicNet)
resource "aws_security_group" "fe_sg" {
  name        = "${var.vpc_name}-sg-fe"
  description = "Allow FE access only from DMZ-PublicNet CIDRs"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.10.40.0/24", "10.10.41.0/24"]
    description = "Allow TCP from DMZ-PublicNet subnets"
  }

  # Permitir que la App hable con la DB (si las aplicaciones en App-privateNet necesitan conectarse a BD,
  # típicamente se permite outbound hacia DB; el SG de DB ya permite inbound desde App subnets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = { Name = "${var.vpc_name}-sg-fe" }
}

# SG para DMZ (frontal público), permitir HTTPs/HTTP desde Internet y permitir egress hacia FE-privateNet
resource "aws_security_group" "dmz_sg" {
  name        = "${var.vpc_name}-sg-dmz"
  description = "Web public SG - allow HTTP/HTTPS from internet and access to App-privateNet"
  vpc_id      = aws_vpc.this.id

  # Inbound desde Internet (ajusta según necesidad)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  # Egress: permitir acceder a FE-privateNet (las dos subnets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.10.32.0/24", "10.10.23.0/24"]
    description = "Allow TCP to App-privateNet"
  }

  # Resto del egress abierto si se requiere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = { Name = "${var.vpc_name}-sg-dmz" }
}

######################################################


# --- Creación VPC interface Endpoint para acceso SSM dedicado
# Security Group para VPC Interface Endpoints (permitir HTTPS desde instancias)
resource "aws_security_group" "ssm_endpoints_sg" {
  name        = "${var.vpc_name}-ssm-endpoints-sg"
  description = "Allow HTTPS from instances to SSM endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow SSM traffic from dmz/fe/app/db SGs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # permitir desde los SGs de instancias (dmz/fe/app/db)
    security_groups = [
      aws_security_group.dmz_sg.id,
      aws_security_group.fe_sg.id,
      aws_security_group.app_sg.id,
      aws_security_group.db_sg.id
    ]
  }

  # Endpoint requires egress to AWS services - allow all outbound from endpoint ENIs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.vpc_name}-ssm-endpoints-sg" }
}

# VPC Interface Endpoint: ssm
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ssm_endpoints_sg.id]
  subnet_ids        = [
    aws_subnet.dmz_pub_az1.id,
    aws_subnet.app_priv_az2.id,
  ]
  private_dns_enabled = true
  tags = { Name = "${var.vpc_name}-vpce-ssm" }
}

# VPC Interface Endpoint: ec2messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ssm_endpoints_sg.id]
  subnet_ids        = [
    aws_subnet.dmz_pub_az1.id,
    aws_subnet.app_priv_az2.id,
  ]
  private_dns_enabled = true
  tags = { Name = "${var.vpc_name}-vpce-ec2messages" }
}

# VPC Interface Endpoint: ssmmessages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ssm_endpoints_sg.id]
  subnet_ids        = [
    aws_subnet.dmz_pub_az1.id,
    aws_subnet.app_priv_az2.id,
  ]
  private_dns_enabled = true
  tags = { Name = "${var.vpc_name}-vpce-ssmmessages" }
}

###########################################
# --- Modulo para prueba con ec2 en cada zona

#module "lab_servers" {
#  #source = "./mod/ec2-testing.tf"
#  source = "./mod"
#
#  region      = var.aws_region
#  name_prefix = "lab"
#
#  # Crear una instancia en cada subnet de la AZ1 
#  subnet_ids = [
#    aws_subnet.db_priv_az1.id,
#    aws_subnet.app_priv_az1.id,
#    aws_subnet.fe_priv_az1.id,
#    aws_subnet.dmz_pub_az1.id
#  ]
#
#  subnet_type_map = {
#    (aws_subnet.db_priv_az1.id) = "db"
#    (aws_subnet.app_priv_az1.id) = "app"
#    (aws_subnet.fe_priv_az1.id) = "fe"
#    (aws_subnet.dmz_pub_az1.id) = "dmz"
#  }
#
#  # Security groups creados en el main
#  db_sg_id  = aws_security_group.db_sg.id
#  app_sg_id = aws_security_group.app_sg.id
#  fe_sg_id  = aws_security_group.fe_sg.id
#  dmz_sg_id = aws_security_group.dmz_sg.id
#
#  # VPC id
#  vpc_id = aws_vpc.this.id
#}
