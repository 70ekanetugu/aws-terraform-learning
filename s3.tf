#
# ALBのアクセスログバケット 
# ===============================================================================
resource "aws_s3_bucket" "alb_log" {
  bucket        = "alb-log-kanetugu-terraform"
  force_destroy = true

  tags = {
    Name = "alb-log"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id     = "rule-1"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}
# ALB->S3用の信頼ポリシー
data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"] # ALBのアカウントID
    }
  }
}
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}
