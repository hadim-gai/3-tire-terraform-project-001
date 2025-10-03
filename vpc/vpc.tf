resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })
}

# creating internet gateway--------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

# creating 2 public subnets---------------------------------------------

resource "aws_subnet" "apci-jupiter_public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}


resource "aws_subnet" "apci-jupiter_public_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1c"
  })
}


# creating 2 private subnets----------------------------------------------


resource "aws_subnet" "apci-jupiter_private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}


resource "aws_subnet" "apci-jupiter_private_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1c"
  })
}

# creating database subnets---------------------------------------------------

resource "aws_subnet" "apci-jupiter_db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
  })
}

resource "aws_subnet" "apci-jupiter_db_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]


tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1c"
  })
}

# creating public route table -------------------------------------------------------------------

resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}

# creating route table association --------------------------------------------------------------

resource "aws_route_table_association" "public_subnet_az_1a" {
  subnet_id      = aws_subnet.apci-jupiter_public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "public_subnet_az_1c" {
  subnet_id      = aws_subnet.apci-jupiter_public_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# creating and elsastic ip for az-1a -------------------------------------------------------------

resource "aws_eip" "eip_az_1a" {
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az_1a"
  })
}

#creating a nat gateway dor az_a1 ------------------------------------------------

resource "aws_nat_gateway" "apic_jupiter_nat_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id
  subnet_id     = aws_subnet.apci-jupiter_public_subnet_az_1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az_1a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1a, aws_subnet.apci-jupiter_public_subnet_az_1a]
}

#creating private route table for az_1a --------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apic_jupiter_nat_az_1a.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1a"
  })
}


# creating private route table association for az-1a ----------------------------------------
resource "aws_route_table_association" "private_subnet_az_1a" {
  subnet_id      = aws_subnet.apci-jupiter_private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

resource "aws_route_table_association" "db_subnet_az_1a" {
  subnet_id      = aws_subnet.apci-jupiter_db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

# creating and elsastic ip for az-1c -------------------------------------------------------------

resource "aws_eip" "eip_az_1c" {
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az_1c"
  })
}

#creating a nat gateway for az_1c ------------------------------------------------

resource "aws_nat_gateway" "apic_jupiter_nat_az_1c" {
  allocation_id = aws_eip.eip_az_1c.id
  subnet_id = aws_subnet.apci-jupiter_public_subnet_az_1c.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az_1c"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1c, aws_subnet.apci-jupiter_public_subnet_az_1c]
}

#creating private route table for az_1c --------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1c" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apic_jupiter_nat_az_1c.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1c"
  })
}


# creating private route table association for az-1c ----------------------------------------
resource "aws_route_table_association" "private_subnet_az_1c" {
  subnet_id      = aws_subnet.apci-jupiter_private_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}

resource "aws_route_table_association" "db_subnet_az_1c" {
  subnet_id      = aws_subnet.apci-jupiter_db_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}

