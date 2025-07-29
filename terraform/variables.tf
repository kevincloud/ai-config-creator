variable "aws_region" {
  description = "The AWS region this application will run in"
  default     = "us-east-2"
}

variable "key_pair" {
  description = "The name of the key pair to use for EC2 instances"
}

variable "unique_identifier" {
  description = "A unique identifier for naming resources to avoid name collisions"
  validation {
    condition     = can(regex("^[a-z]{6,10}$", var.unique_identifier))
    error_message = "unique_identifier must be lower case letters only and 6 to 10 characters in length"
  }
}

variable "ld_api_key" {
  description = "LaunchDarkly API key"
}

variable "owner" {
  description = "Your email address"
}
