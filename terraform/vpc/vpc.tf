
#CREATING MAIN VPC--------------------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main_vpc"{
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
})
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
})
}

# CREATING PUBLIC SUBNETS---------------------------------------- --------------------------------------------------------------------------
resource "aws_subnet" "public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
})
}

resource "aws_subnet" "public_subnet_az_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1b"
})
}

# CREATING PRIVATE SUBNETS---------------------------------------- --------------------------------------------------------------------------

resource "aws_subnet" "private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[2]
  availability_zone = var.availability_zone[0]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
})
}

resource "aws_subnet" "private_subnet_az_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[3]
  availability_zone = var.availability_zone[1]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1b"
})
}

# CREATING DB SUBNETS---------------------------------------- --------------------------------------------------------------------------

resource "aws_subnet" "db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[4]
  availability_zone = var.availability_zone[0]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
})
}

resource "aws_subnet" "db_subnet_az_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnet_cidr_block[5]
  availability_zone = var.availability_zone[1]

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1b"
})
}

# CREATING PUBLIC ROUTE TABLE------------------------------------------------------------------------
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
})
}

# CREATING SUBNET ASSOCIATION FOR PUBLIC SUBNET---------------------------------------------------------------------
resource "aws_route_table_association" "public_association-az-1a" {
  subnet_id      = aws_subnet.public_subnet_az_1a.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "public_association-az-1b" {
  subnet_id      = aws_subnet.public_subnet_az_1b.id
  route_table_id = aws_route_table.public-rt.id
}

# CREATING ELASTIC IP FOR NATGATEWAY az 1a----------------------------------------------
resource "aws_eip" "eip_az_1a" {
  domain   = "vpc"

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
})
}

# CREATING NATGATEWAY az 1a ----------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id
  subnet_id     = aws_subnet.db_subnet_az_1a.id

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
})

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1a, aws_subnet.public_subnet_az_1a]
}

# CREATING PRIVATE ROUTE TABLE az 1a--------------------------------------------------------------------------------------------
resource "aws_route_table" "private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_1a.id
  }
  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1a"
})
}

#CREATING SUBNET ASSOCIATION FOR PRIVATE ROUTE TABLE FOR AZ 1a ---------------------------------------------------------------------
resource "aws_route_table_association" "private_association-az-1a" {
  subnet_id      = aws_subnet.private_subnet_az_1a.id
  route_table_id = aws_route_table.private_rt_az_1a.id
}
resource "aws_route_table_association" "db_association-az-1a" {
  subnet_id      = aws_subnet.db_subnet_az_1a.id
  route_table_id = aws_route_table.private_rt_az_1a.id
}

# CREATING ELASTIC IP FOR NATGATEWAY az 1b----------------------------------------------
resource "aws_eip" "eip_az_1b" {
  domain   = "vpc"

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1b"
})
}

# CREATING NATGATEWAY az 1b ----------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_1b" {
  allocation_id = aws_eip.eip_az_1b.id
  subnet_id     = aws_subnet.public_subnet_az_1b.id

  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1b"
})

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1b, aws_subnet.public_subnet_az_1b]
}

# CREATING PRIVATE ROUTE TABLE az 1b--------------------------------------------------------------------------------------------
resource "aws_route_table" "private_rt_az_1b" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_1b.id
  }
  tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1b"
})
}

#CREATING SUBNET ASSOCIATION FOR PRIVATE ROUTE TABLE FOR AZ 1b ---------------------------------------------------------------------
resource "aws_route_table_association" "private_association-az-1b" {
  subnet_id      = aws_subnet.private_subnet_az_1b.id
  route_table_id = aws_route_table.private_rt_az_1b.id
}
resource "aws_route_table_association" "db_association-az-1b" {
  subnet_id      = aws_subnet.db_subnet_az_1b.id
  route_table_id = aws_route_table.private_rt_az_1b.id
}