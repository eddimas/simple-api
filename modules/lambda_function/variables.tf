variable "function_name" {}
variable "runtime" {}
variable "handler" {}
variable "s3_bucket" {}
variable "s3_key" {}
variable "role" {}
variable "environment_variables" {
  type = map(string)
}
