output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}

output "s3_bucket_name" {
    value = aws_s3_bucket.bucket.id
}