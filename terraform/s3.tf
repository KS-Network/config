# FE bucket
resource "aws_s3_bucket" "fe_bucket" {
  bucket = format("%s-fe-bucket", var.name_prefix)
}

### Bucket ACL setting
resource "aws_s3_bucket_acl" "fe_bucket_acl" {
  bucket = aws_s3_bucket.fe_bucket.id
  acl    = "private"
}

# data "aws_iam_policy_document" "fe_bucket_policy" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.fe_bucket.arn}/*"]
#
#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.fe_oai.iam_arn]
#     }
#   }
# }
#
# resource "aws_s3_bucket_policy" "fe_bucket_policy" {
#   bucket = aws_s3_bucket.fe_bucket.id
#   policy = data.aws_iam_policy_document.fe_bucket_policy.json
# }
