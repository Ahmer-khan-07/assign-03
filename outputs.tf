output "vpc_id" {
  value = aws_vpc.main.id
}

output "instance_id" {
  value = aws_instance.example.id
}

output "bucket_arn" {
  value = aws_s3_bucket.b.arn
}
