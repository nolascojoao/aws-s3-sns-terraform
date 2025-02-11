resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_sns_topic" "sns_topic" {
  name = "${var.bucket_name}-sns-topic"
}

resource "aws_sns_topic_subscription" "sns_email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.sns_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

data "aws_iam_policy_document" "sns_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["SNS:Publish"]

    resources = [aws_sns_topic.sns_topic.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.sns_policy_doc.json
}
