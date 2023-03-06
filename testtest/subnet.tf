resource "aws_subnet" "public_a" {
    vpc_id  =  "${aws_vpc.iron.id}"
    availability_zone   =   "ap-northeast-2a"
    cidr_block = "172.20.1.0/24"
    
    tags = {
        Name = "public_a"
    }
}


resource "aws_subnet" "private_a" {
    vpc_id = "${aws_vpc.iron.id}"
    availability_zone = "ap-northeast-2a"
    cidr_block = "172.20.101.0/24"

    tags = {
        Name = "private_a"
    }
}

resource "aws_subnet" "public_c" {
    vpc_id  =  "${aws_vpc.iron.id}"
    availability_zone   =   "ap-northeast-2c"
    cidr_block = "172.20.2.0/24"
    
    tags = {
        Name = "public_c"
    }
}

resource "aws_subnet" "private_c" {
    vpc_id = "${aws_vpc.iron.id}"
    availability_zone = "ap-northeast-2c"
    cidr_block = "172.20.102.0/24"

    tags = {
        Name = "private_c"
    }
}


####EKS PRIVATE SUBNET

resource "aws_subnet" "private_eks1" {
    vpc_id = "${aws_vpc.iron.id}"
    availability_zone = "ap-northeast-2a"
    cidr_block = "172.20.103.0/24"

    tags = {
        Name = "private-eks"
    }
}

resource "aws_subnet" "private_eks2" {
    vpc_id = "${aws_vpc.iron.id}"
    availability_zone = "ap-northeast-2c"
    cidr_block = "172.20.104.0/24"

    tags = {
        Name = "private-eks"
    }
}

