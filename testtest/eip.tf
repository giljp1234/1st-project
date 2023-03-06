#리전별로 EIP 한개씩 

resource "aws_eip" "iron_eip_a" {
    vpc = true
}

resource "aws_eip" "iron_eip_c" {
    vpc = true
}