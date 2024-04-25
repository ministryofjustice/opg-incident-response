data "aws_elb_service_account" "main" {
  region = "eu-west-1"
}

data "aws_iam_policy_document" "loadbalancer" {
  statement {
    sid = "accessLogBucketAccess"

    resources = [
      aws_s3_bucket.access_log.arn,
      "${aws_s3_bucket.access_log.arn}/*",
    ]

    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      identifiers = [data.aws_elb_service_account.main.id]

      type = "AWS"
    }
  }
}

resource "aws_s3_bucket" "access_log" {
  bucket        = "incident-response-${local.environment}-lb-access-log"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_object_ownership" {
  bucket = aws_s3_bucket.access_log.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.access_log.id

  rule {
    id     = "ExpireObjectsAfter13Months"
    status = "Enabled"

    expiration {
      days = 400
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_log" {
  bucket = aws_s3_bucket.access_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_policy" {
  bucket = aws_s3_bucket.access_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "access_log" {
  bucket = aws_s3_bucket.access_log.id
  policy = data.aws_iam_policy_document.loadbalancer.json
}
