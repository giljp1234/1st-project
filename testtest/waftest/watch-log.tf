#s3 에 cloudwatch Log 
resource "aws_cloudwatch_log_group" "iron-watch" {
  name              = "iron-watch-log-group"
  retention_in_days = 14

  depends_on = [aws_s3_bucket.log]
}

resource "aws_cloudwatch_log_stream" "iron-watch" {
  name           = "iron-watch-log-stream"
  log_group_name = aws_cloudwatch_log_group.iron-watch.name

}


resource "aws_cloudwatch_log_destination" "watch-destination" {
  name = "watch-destination"
  role_arn = aws_iam_role.iron-role.arn
  target_arn = "arn:aws:s3:::soldesk-s3-test"


  depends_on = [
    aws_cloudwatch_log_group.iron-watch,
    aws_iam_role_policy_attachment.iron-cloudwatch-logs-attachment,
    aws_iam_role.iron-role,
    aws_s3_bucket.log,
  ]
}

resource "aws_cloudwatch_log_destination_policy" "iron_destination_policy" {
  destination_name = aws_cloudwatch_log_destination.watch-destination.name
  access_policy = data.aws_iam_policy_document.watch_destination_policy.json
}

data "aws_iam_policy_document" "watch_destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = toset([var.id_number])
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "logs:PutSubscriptionFilter"
    ]

    resources = [
      aws_cloudwatch_log_destination.watch-destination.arn
    ]
  }
  depends_on = [
    aws_cloudwatch_log_destination_policy.watch-policy,
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "destination" {
  name            = "watch-destination"
  role_arn        = aws_iam_role.eks_node.arn
  log_group_name  = aws_cloudwatch_log_group.iron-watch.name
  filter_pattern  = ""
  destination_arn = aws_cloudwatch_log_destination.watch-destination.arn

  depends_on = [
    aws_iam_role_policy_attachment.node2_policy,
  ]
}

data "aws_security_group" "private-eks" {
    name   = "private-eks"
    depends_on = [
      aws_security_group.private-eks
    ]
}


resource "aws_iam_role" "iron-role" {
    name = "iron-role"

    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "logs.amazonaws.com"
            }
        }
      ]    
    })
}
resource "aws_iam_role_policy_attachment" "iron_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.iron-role.name
}

resource "aws_iam_role_policy_attachment" "iron-cloudwatch-logs-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLogsReadOnlyAccess"
  role       = aws_iam_role.iron-role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.iron-role.name
}
resource "aws_cloudwatch_log_destination_policy" "watch-policy" {
  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          type = "logs.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:PutSubscriptionFilter",
          "iam:PassRole"

        ]
        Resource = [
          "${aws_s3_bucket.log.arn}",
          "${aws_s3_bucket.log.arn}/*"
        ]
      }
    ]
  })

  destination_name = aws_cloudwatch_log_destination.watch-destination.name
}

#Node log S3 저장
resource "aws_cloudwatch_log_group" "eks_group" {
  name = "/aws/eks/iron-eks"
  retention_in_days = 30
}

data "aws_eks_cluster" "iron-eks" {
  name = "iron-eks"
  depends_on = [
    aws_eks_cluster.iron-eks
  ]
}

data "aws_eks_cluster_auth" "iron-eks_cluster" {
  name = data.aws_eks_cluster.iron-eks.name
}


resource "aws_cloudwatch_log_subscription_filter" "node_logs" {
  name            = "eks-node-logs"
  role_arn        = aws_iam_role.eks_node.arn
  log_group_name  = aws_cloudwatch_log_group.eks_group.name
  filter_pattern  = ""
  destination_arn = aws_cloudwatch_log_destination.watch-destination.arn

  depends_on = [
    aws_iam_role_policy_attachment.node2_policy,
  ]
}

resource "aws_launch_configuration" "node_launch_config" {
  name_prefix   = "my-launch-config"
  image_id      = data.aws_ami.node_ami.id
  instance_type = "t3.small"

  lifecycle {
    create_before_destroy = true
  }
  security_groups = [
    data.aws_security_group.private-eks.id,
  ]

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
  ]
}

