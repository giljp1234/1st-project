# eks node cloudwatch 그룹
resource "aws_cloudwatch_log_group" "eks_nodes" {
  name = "/aws/eks/${var.eks_cluster}/eks-nodes"

  tags = {
    Terraform = "true"
  }
}

resource "aws_cloudwatch_log_stream" "eks_nodes" {
  name = "eks-nodes"
  log_group_name = aws_cloudwatch_log_group.eks_nodes.name

  depends_on = [
    aws_cloudwatch_log_group.eks_nodes,
  ]
}

resource "aws_iam_role" "eks_node_cloudwatch_logs" {
  name = "eks-node-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_cloudwatch_logs_test-1" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role = aws_iam_role.eks_node_cloudwatch_logs.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cloudwatch_logs_test-2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.eks_node_cloudwatch_logs.name
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = <<EOF
      aws logs put-subscription-filter \
        --log-group-name ${aws_cloudwatch_log_group.eks_nodes.name} \
        --filter-name ${aws_cloudwatch_log_subscription_filter.eks_node_group_logs_filter.name} \
        --filter-pattern "" \
        --destination-arn ${aws_s3_bucket.logs_bucket.arn} \
        --role-arn ${aws_iam_role.eks_node_cloudwatch_logs.arn}
    EOF
  }
  depends_on = [
    aws_instance.bastion_a
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "eks_node_group_logs_filter" {
  name            = "eks-node-group-filter"
  log_group_name  = aws_cloudwatch_log_group.eks_nodes.name
  filter_pattern  = ""
  destination_arn = "arn:aws:s3:::eks-node-group-logs-bucket"
  role_arn        = aws_iam_role.eks_node_cloudwatch_logs.arn

  depends_on = [
    aws_s3_bucket_policy.logs_bucket_policy,
    aws_cloudwatch_log_stream.eks_nodes,
  ]
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
          
        ]
        Effect    = "Allow"
        Resource  = [
          "${aws_s3_bucket.logs_bucket.arn}",
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
        Principal = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "logs_bucket" {
    bucket = "eks-node-group-logs-bucket"
    acl = "private"
  tags = {
    Terraform   = "true"
  }
}
resource "aws_s3_bucket_acl" "acl_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
  acl = "private"
}


