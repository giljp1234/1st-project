
resource "aws_s3_bucket" "log" {
    bucket = "soldesk-s3-test"
    
    lifecycle {
      prevent_destroy = false
    }
    tags = {
        Name = "soldesk-s3-log-test"
    }
}
resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
    bucket = aws_s3_bucket.log.id
    rule {
        id = "log-rule"

        filter {
            prefix = "logs/"
        }
        status = "Enabled"
        transition {
            days = 30
            storage_class = "STANDARD_IA"
        }
    }
    
}


resource "aws_s3_bucket_acl" "acl" {
    bucket = aws_s3_bucket.log.id
    acl = "private"
}

resource "aws_s3_bucket_versioning" "versioning_s3" {
  bucket = aws_s3_bucket.log.id
  versioning_configuration {
    status = "Enabled"
  }
}

