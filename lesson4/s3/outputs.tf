output "buckets_name" {
    value = aws_s3_bucket.bucket[*].id
}