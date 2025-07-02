# ===============================
# File Virus Checker Lambda
# ===============================
resource "aws_lambda_function" "file_virus_checker" {
  function_name = "fluum-file-virus-checker-${var.env_name}"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.file_virus_checker.repository_url}:latest"
  role          = aws_iam_role.lambda_file_virus_checker_role.arn
  timeout       = 300

  environment {
    variables = {
      CONTENT_FILES_BUCKET = aws_s3_bucket.content_files.bucket
      MONGO_URI            = var.mongo_uri
      MONGO_DB_NAME        = var.mongo_db_name
      SUPABASE_URL         = var.supabase_url
      SUPABASE_KEY         = var.supabase_key
    }
  }
}

resource "aws_cloudwatch_log_group" "file_virus_checker" {
  name              = "/aws/lambda/${aws_lambda_function.file_virus_checker.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_file_virus_checker_role" {
  name = "fluum-file-virus-checker-${var.env_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy" "lambda_file_virus_checker_policy" {
  name = "fluum-file-virus-checker-${var.env_name}-policy"
  role = aws_iam_role.lambda_file_virus_checker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.quarantine_files.arn}",
          "${aws_s3_bucket.quarantine_files.arn}/*"
        ]
      }
    ]
  })
}

# S3 bucket notification to trigger file_virus_checker Lambda
resource "aws_s3_bucket_notification" "quarantine_bucket_notification" {
  bucket = aws_s3_bucket.quarantine_files.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_virus_checker.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_virus_checker.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.quarantine_files.arn
}
