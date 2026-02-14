terraform {
  backend "s3" {
    bucket         = "eks-tf-state-sudhikumar"
    key            = "staging/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "eks-tf-lock"
    encrypt        = true
  }
}
