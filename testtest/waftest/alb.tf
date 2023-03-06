resource "aws_security_group" "alb-sg" {
  name_prefix = "alb-sg"
  vpc_id = aws_vpc.iron.id

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "alb-ingress-rule" {
  type = "ingress"
  security_group_id = aws_security_group.alb-sg.id
  protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "iron-lb" {
  name = "iron-lb"
  internal = false
  load_balancer_type = "application"
  
  security_groups = [aws_security_group.alb-sg.id]
  subnets = [aws_subnet.private_eks1.id, aws_subnet.private_eks2.id]
  enable_deletion_protection = false # true 는 삭제 방지
  
  tags = {
    name = "iron-lb"
    Terraform = "true"
  }
  access_logs {
    enabled = true
    bucket = aws_s3_bucket.alb_logs_bucket.bucket
  }
}


#target
resource "aws_lb_target_group" "ironTG" {
  name_prefix = "ironTG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.iron.id

  health_check {
    interval = 30
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = {
    name = "iron-tg"
  }
}



resource "aws_lb_target_group_attachment" "iron-target-group1" {
  count = length(data.aws_instance.node_group_instances.*.id)
  
  target_group_arn = aws_lb_target_group.ironTG.arn
  target_id = data.aws_instance.node_group_instances[count.index].id

  depends_on = [
    aws_eks_cluster.iron-eks,
    aws_lb_target_group.ironTG
  ]
}



resource "aws_lb_listener" "iron-lb-listener" {
  load_balancer_arn = aws_lb.iron-lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ironTG.arn
  }
}

/*
resource "aws_autoscaling_attachment" "iron-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.iron_asg.name
  alb_target_group_arn = aws_lb_target_group.ironTG.arn
}



resource "aws_autoscaling_group" "iron_asg" {
  name = "iron_asg"
  launch_configuration = aws_launch_configuration.
}
*/
resource "aws_launch_configuration" "iron-lc" {
  name = "iron-lc-${var.eks_cluster}"

  image_id = "ami-0c94855ba95c71c99"
  instance_type = "t2.small"
  security_groups = [aws_security_group.private-eks.id]

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_security_group.private-eks,
  ]
}

resource "aws_autoscaling_group" "iron-asg" {
  name_prefix = "iron-asg"

  desired_capacity = 2
  max_size = 2
  min_size = 2

  launch_configuration = aws_launch_configuration.iron-lc.name
  vpc_zone_identifier = [aws_subnet.private_eks1.id, aws_subnet.private_eks2.id]

  tag {
    key = "Name"
    value = "iron-node-group"
    propagate_at_launch = true
  }

  depends_on = [
    aws_launch_configuration.iron-lc,
    ]
}

data "aws_instance" "node_group_instances" {
  count = 2

  filter {
    name = "tag:Name"
    values = ["iron-node-group"]
  }

  depends_on = [
    aws_autoscaling_group.iron-asg,
  ]
}