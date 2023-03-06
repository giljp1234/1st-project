###인터넷 게이트웨이랑 public subnet을 라우트로 연결

##Availaility Zone A
resource "aws_route_table" "route_public_a" {
    vpc_id = "${aws_vpc.iron.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.i-igw.id}"
    }

    tags = {
        Name = "route_public_a"
    }
}

resource "aws_route_table_association" "route_a_public" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = "${aws_route_table.route_public_a.id}"
}
##Availaility Zone C
resource "aws_route_table" "route_public_c" {
    vpc_id = "${aws_vpc.iron.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.i-igw.id}"
    }

    tags = {
        Name = "route_public_c"
    }
}

resource "aws_route_table_association" "route_c_public" {
    subnet_id = aws_subnet.public_c.id
    route_table_id = "${aws_route_table.route_public_c.id}"
}



#-----------------------------------------------------------------#

#EKS private 이랑 public 에 nat 랑 연결
##private_EKS1

resource "aws_route_table" "eks_private_a" {
    vpc_id = "${aws_vpc.iron.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_a.id
    }

    tags = {
        Name = "eks_private_a"
    }
}

resource "aws_route_table_association" "eks_private_a" {
    subnet_id = "${aws_subnet.private_eks1.id}"
    route_table_id = "${aws_route_table.eks_private_a.id}"
}

##private_EKS2
resource "aws_route_table" "eks_private_c" {
    vpc_id = "${aws_vpc.iron.id}"

    route {
        cidr_block = "0.0.0.0/0"
         nat_gateway_id = aws_nat_gateway.nat_c.id
    }

    tags = {
        Name = "eks_private_c"
    }
}

resource "aws_route_table_association" "eks_private_c" {
    subnet_id = "${aws_subnet.private_eks2.id}"
    route_table_id = "${aws_route_table.eks_private_c.id}"
}






