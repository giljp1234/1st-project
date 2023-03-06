data "aws_ami" "node_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.21*"]
  }

  owners = ["amazon"]
}

