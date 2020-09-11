provider "aws" {
  profile    = "${var.profile}"
  version    = "~> 2.64"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "terraform-remote-state-storage-s3-cynerge-infra-team-v1"
    key    = "key-shipyard-maven/"
    region = "us-east-2"
  }
}