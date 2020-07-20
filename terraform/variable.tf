
variable "bucket_name" {
  type        = "string"
  description = "The bucket name"
  #default     = "springcloudpdf"
  default     = "lambda-fs-demo"
}

variable "git_marker" {
  type = "string"
  description = "The git source code git marker, this can be a commit hash, a tag name, branch name"
  default     = "tempbranch"
}

variable "environment" {
  type = "string"
  description = "The name of the environment within the project"
  default     = "dev"
}

variable "lambda_runtime_java" {
  type = "string"
  description = "The name of the runtime selected form the dropdown"
  default     = "java8"
}

variable "lambda_invoke_type" {
  type = "string"
  description = "Type of invocation used eg. sync or Async"
  default     = "Asynchronous"
}

