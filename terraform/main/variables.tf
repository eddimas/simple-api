variable "region_name" {
  type    = string
  default = "us-east-1"
}

variable "bucket_data_name" {
  type    = string
  default = "device-raw-data-bucket"
}

variable "bucket_tfstate_name" {
  type    = string
  default = "terraform-20250227182101774700000002"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "stage_name" {
  type    = string
  default = "test"
}

variable "api_gw_name" {
  type    = string
  default = "device_event_api"
}

variable "api_gw_description" {
  type    = string
  default = "TF API Gateway challenge"
}

variable "api_gw_path" {
  type    = string
  default = "api"
}

variable "dynamodb_table_name" {
  type    = string
  default = "ProcessedData"
}

variable "dynamodb_table_hash_key" {
  type    = string
  default = "device_id"

}
