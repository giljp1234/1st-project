resource "aws_internet_gateway" "i-igw" {
    vpc_id = "${aws_vpc.iron.id}"

    tags = {
        Name = "i-igw"
    }
}