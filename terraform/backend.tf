terraform {
  backend "s3" {
    bucket       = "ecom-infra-tfstate-depi1"
    key          = "ecom-infra/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
