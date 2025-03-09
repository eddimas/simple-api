variable "region_name" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "bucket_data_name" {
  type        = string
  description = "The name of the S3 bucket for storing raw data"
  default     = "device-raw-data-bucket"
}

variable "bucket_tfstate_name" {
  type        = string
  description = "The name of the S3 bucket for storing Terraform state"
  default     = "terraform-20250227182101774700000002"
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function"
  default     = "python3.9"
}

variable "stage_name" {
  type        = string
  description = "The stage name for the API Gateway"
  default     = "test"
}

variable "api_gw_name" {
  type        = string
  description = "The name of the API Gateway"
  default     = "device_event_api"
}

variable "api_gw_description" {
  type        = string
  description = "The description of the API Gateway"
  default     = "TF API Gateway challenge"
}

variable "api_gw_path" {
  type        = string
  description = "The path part of the API Gateway resource"
  default     = "api"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
  default     = "ProcessedData"
}

variable "dynamodb_table_hash_key" {
  type        = string
  description = "The hash key for the DynamoDB table"
  default     = "device_id"
}

variable "dynamodb_table_sort_key" {
  type        = string
  description = "The hash key for the DynamoDB table"
  default     = "timestamp"
}

# Variables for API Key and Usage Plan
variable "api_key_name" {
  type        = string
  description = "The name of the API key"
  default     = "client-api-key"
}

variable "api_key_description" {
  type        = string
  description = "The description of the API key"
  default     = "API Key for secured API access"
}

variable "usage_plan_name" {
  type        = string
  description = "The name of the usage plan"
  default     = "api-usage-plan"
}

variable "usage_plan_description" {
  type        = string
  description = "The description of the usage plan"
  default     = "Usage plan for secured API Gateway"
}

variable "rate_limit" {
  type        = number
  description = "The rate limit for the usage plan"
  default     = 10
}

variable "burst_limit" {
  type        = number
  description = "The burst limit for the usage plan"
  default     = 5
}

variable "device_csv_data_bucket" {
  type    = string
  default = "device-raw-data-bucket"
}
