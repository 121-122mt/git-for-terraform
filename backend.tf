terraform {
  backend "s3" {
    bucket         = "terraform-bucket-s31234"
    key            = "ec2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "table12"
  }
}