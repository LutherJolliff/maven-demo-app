provider "aws" {
  version    = "~> 2.64"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "fs-workflow-74836"
    key    = "fs-workflow/state.tfvars"
    region = "us-gov-east-1"
  }
}