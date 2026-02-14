terraform {
  backend "s3" {
    bucket         = "eks-tf-state-sudhikumar"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "eks-tf-lock"
    encrypt        = true
  }
}
