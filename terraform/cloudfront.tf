# Global Certificate
resource "aws_acm_certificate" "global_cert" {
  provider                  = aws.virginia
  domain_name               = var.hz_main_name
  subject_alternative_names = [format("*.%s", var.hz_main_name)]
  validation_method         = "DNS"
}

## ACM Validation
resource "aws_acm_certificate_validation" "global_cert_validate" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.global_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.hz_main_record_certverify : record.fqdn]
}

# CloudFront Distribution
## OAIs
resource "aws_cloudfront_origin_access_identity" "fe_distribution_oai" {
}

## Distributions
resource "aws_cloudfront_distribution" "fe_distribution" {
  aliases         = [var.hz_main_name]
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.global_cert.arn
    ssl_support_method  = "sni-only"
  }

  #############################################
  # Precedence 0) ALB
  #############################################
  # Origin
  origin {
    domain_name = aws_alb.alb_main.dns_name
    origin_id   = aws_alb.alb_main.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Behavior
  ordered_cache_behavior {
    path_pattern     = "/api*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.alb_main.id

    forwarded_values {
      query_string = true  # Forward all query_string
      headers      = ["*"] # Forward all headers

      cookies {
        forward = "all" # Forward all cookies
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  #############################################
  # Default precedence) S3:store webview bucket
  #############################################
  default_root_object = "index.html"

  # Origin
  origin {
    domain_name = aws_s3_bucket.fe_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.fe_bucket.id
    origin_path = "/build"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.fe_distribution_oai.cloudfront_access_identity_path
    }
  }

  # Behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.fe_bucket.id

    forwarded_values {
      query_string = true # Forward all query_string

      cookies {
        forward = "all" # Forward all cookies
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # SPA support: 404 handling
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
}
