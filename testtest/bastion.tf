locals {
    eksctl_version = "0.70.0"
}
data "template_file" "bastion_user_data" {
  template = "${file("bastion.sh")}"

  vars = {
    EKSCTL_VERSION = local.eksctl_version
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    region            = "${var.region}"
    eks_cluster      = "${var.eks_cluster}"
  }
}

resource "aws_instance" "bastion_a" {
    ami = "ami-0f6e451b865011317"
    availability_zone = "ap-northeast-2a"
    instance_type = "t2.micro"
    key_name = "testiron"

    vpc_security_group_ids = [
        "${aws_security_group.bastion.id}",
    ]

    subnet_id = "${aws_subnet.public_a.id}"
    associate_public_ip_address = true
    /*connection {
        type = "ssh"
        user = "ec2-user"
        agent = "true"
        private_key = file("/Users/nochek/noche.pem")
        host = self.public_ip*/
    user_data = <<-EOF
                #!bin/bash
                # Set AWS CLI credentials
                aws configure set aws_access_key_id "AKIARSI5JEKQTRT6RCXY"
                aws configure set aws_secret_access_key "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"
                aws configure set region "ap-northeast-2"
                aws configure set output "json"

                curl -LO https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl
                chmod +x ./kubectl
                mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
                echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
                aws eks update-kubeconfig --region ap-northeast-2 --name iron-eks

                sudo yum install -y python
                EOF
    
   
    tags = {
        Name = "bastion_a"
    }
}

resource "aws_security_group" "bastion" {
    name = "bastion"
    description = "open ssh port for bastion"

    vpc_id = "${aws_vpc.iron.id}"
#ssh 만 열어두기 bastion
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 1194
        to_port = 1194
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

    tags = {
        Name = "bastion"
    }
}

resource "aws_eip" "bastion_a_eip" {
    instance = "${aws_instance.bastion_a.id}"
    vpc = true
}
