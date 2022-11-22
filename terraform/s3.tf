# FE bucket
resource "aws_s3_bucket" "fe_bucket" {
  bucket = format("%s-fe-bucket", var.name_prefix)
}

# S3 Website
resource "aws_s3_bucket_website_configuration" "fe_bucket_webhost" {
  bucket = aws_s3_bucket.fe_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

### Bucket ACL setting
resource "aws_s3_bucket_acl" "fe_bucket_acl" {
  bucket = aws_s3_bucket.fe_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "fe_bucket_policy" {
  bucket = aws_s3_bucket.fe_bucket.id
  policy = data.aws_iam_policy_document.s3_read_all_policy.json
}

data "aws_iam_policy_document" "s3_read_all_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "arn:aws:s3:::${format("%s-fe-bucket", var.name_prefix)}/*"
    ]
  }
}
