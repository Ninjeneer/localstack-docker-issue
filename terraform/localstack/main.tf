provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  endpoints {
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    iam        = "http://localhost:4566"
    logs       = "http://localhost:4566"
    s3         = "http://localhost:4566"
    ecr        = "http://localhost:4566"
  }
}
