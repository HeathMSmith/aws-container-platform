terraform {
  backend "s3" {
    bucket       = "hms-terraform-state-portfolio"
    key          = "container-platform/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
