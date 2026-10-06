# 1. Primary VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cloudops-${var.environment}-vpc"
  }
}

# 2. Internet Gateway for Public Subnets
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudops-${var.environment}-igw"
  }
}

# 3. Public Subnets (ALB & EC2 Container Hosts)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudops-${var.environment}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# 4. Private Application Subnets (Internal microservices without internet egress)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "cloudops-${var.environment}-private-app-subnet-${count.index + 1}"
    Type = "PrivateApp"
  }
}

# 5. Isolated Database Subnets (RDS PostgreSQL)
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "cloudops-${var.environment}-isolated-db-subnet-${count.index + 1}"
    Type = "Database"
  }
}

# 6. Route Table - Public Subnets (Outbound Internet Access via IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "cloudops-${var.environment}-public-rt"
  }
}

# 7. Route Table - Private Application Subnets (Local VPC Traffic Only)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudops-${var.environment}-private-rt"
  }
}

# 8. Route Table - Isolated Database Subnets (Local VPC Traffic Only)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudops-${var.environment}-db-rt"
  }
}

# 9. Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# 10. DB Subnet Group for RDS Integration
resource "aws_db_subnet_group" "database" {
  name       = "cloudops-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "cloudops-${var.environment}-db-subnet-group"
  }
}
