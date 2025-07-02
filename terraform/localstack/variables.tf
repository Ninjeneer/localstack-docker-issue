variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "supabase_url" {
  type        = string
  description = "Supabase URL"
}

variable "supabase_key" {
  type        = string
  description = "Supabase key"
}

variable "env_name" {
  type        = string
  description = "Environment name"
  default     = "local"
}

variable "mongo_uri" {
  type        = string
  description = "Mongo URI"
}

variable "mongo_db_name" {
  type        = string
  description = "Mongo DB name"
}

variable "frontend_url" {
  type        = string
  description = "Frontend URL"
}
