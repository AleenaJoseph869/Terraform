provider "aws" {
    region = "ap-southeast-1"
    access_key = "AKIAQGGOAJ363G6LDPT3"
    secret_key = "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"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}

resource "aws_vpc" "aleena-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "aleena-subnet-1" {
    vpc_id = aws_vpc.aleena-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
} 


resource "aws_internet_gateway" "aleena-igw" {
    vpc_id = aws_vpc.aleena-vpc.id
     tags = {
        Name:  "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "al-rtb" {
    default_route_table_id = aws_vpc.aleena-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aleena-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_security_group" "al-sg" {
    name = "al-sg"
    vpc_id = aws_vpc.aleena-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
         Name: "${var.env_prefix}-sg"
    }
}

