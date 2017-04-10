# Terraform envionment build

# Provide credentials and reigon in variables

provider "aws" {}


# Create VPC

resource "aws_vpc" "vpc_tuto" {
  cidr_block = "10.10.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TerraformTestVPC"
  }
}

# Create public subnet

resource "aws_subnet" "public_subnet_eu_west_1a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
  tags = {
  	Name =  "Public_Subnet_1a"
  }
}

# Create private subnets

resource "aws_subnet" "private_1_subnet_eu_west_1b" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "10.10.2.0/24"
  availability_zone = "eu-west-1b"
  tags = {
  	Name =  "Private_Subnet_1b"
  }

}

resource "aws_subnet" "private_2_subnet_eu_west_1c" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "10.10.3.0/24"
  availability_zone = "eu-west-1c"
  tags = {
  	Name =  "Private_Subnet_1c"
  }
}

# Create VPC internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_tuto.id}"
  tags {
        Name = "InternetGateway"
    }
}

# Create route to for internet access

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_tuto.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Create EIP for NAT gateway

resource "aws_eip" "tuto_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create NAT gateway

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.tuto_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_eu_west_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

# Create route table

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_tuto.id}"

    tags {
        Name = "Private route table"
    }
}

# Create associations

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Associate subnet public_subnet_eu_west_1a to public route table
resource "aws_route_table_association" "public_subnet_eu_west_1a_association" {
    subnet_id = "${aws_subnet.public_subnet_eu_west_1a.id}"
    route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
}

# Associate subnet private_1_subnet_eu_west_1a to private route table
resource "aws_route_table_association" "pr_1_subnet_eu_west_1a_association" {
    subnet_id = "${aws_subnet.private_1_subnet_eu_west_1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# Associate subnet private_2_subnet_eu_west_1a to private route table
resource "aws_route_table_association" "pr_2_subnet_eu_west_1a_association" {
    subnet_id = "${aws_subnet.private_2_subnet_eu_west_1c.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
