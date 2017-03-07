provider "aws" {
  region = "ca-central-1"
}

data "aws_route53_zone" "main" {
  name = "luciachoi.com."
}

data "aws_iam_policy_document" "main" {
    statement {
        sid = "AddPerm"
        effect = "Allow"
        principals {
            type = "AWS"
            identifiers = ["*"]
        }
        actions = [
            "s3:GetObject"
        ]
        resources = [
            "arn:aws:s3:::luciachoi.com/*",
        ]
    }
}

resource "aws_s3_bucket" "primary" {
  bucket = "luciachoi.com"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.main.json}"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "secondary" {
  bucket = "www.luciachoi.com"
  acl = "public-read"

  website {
    redirect_all_requests_to = "luciachoi.com"
  }
}

resource "aws_route53_record" "primary" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name = "luciachoi.com"
  type = "A"

  alias {
    name = "${aws_s3_bucket.primary.website_domain}"
    zone_id = "${aws_s3_bucket.secondary.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name = "www.luciachoi.com"
  type = "A"

  alias {
    name = "${aws_s3_bucket.secondary.website_domain}"
    zone_id = "${aws_s3_bucket.secondary.hosted_zone_id}"
    evaluate_target_health = false
  }
}
