# ===============================
# Quarantine Files Bucket
# ===============================
resource "aws_s3_bucket" "quarantine_files" {
  bucket = "fluum-${var.env_name}-quarantine-files"

  tags = {
    Name = "fluum-${var.env_name}-quarantine-files"
    env  = var.env_name
  }
}

resource "aws_s3_bucket_public_access_block" "quarantine_files" {
  bucket = aws_s3_bucket.quarantine_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "quarantine_files" {
  bucket = aws_s3_bucket.quarantine_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "HEAD"]
    allowed_origins = [var.frontend_url]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ===============================
# Content Files Bucket
# ===============================
resource "aws_s3_bucket" "content_files" {
  bucket = "fluum-${var.env_name}-content-files"

  tags = {
    Name = "fluum-${var.env_name}-content-files"
    env  = var.env_name
  }
}

resource "aws_s3_bucket_public_access_block" "content_files" {
  bucket = aws_s3_bucket.content_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "content_files" {
  bucket = aws_s3_bucket.content_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = [var.frontend_url]
  }
}
