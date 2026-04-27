terraform {
  backend "local" {
    path = "/home/bob/terraform/env/prod/terraform.tfstate"
  }
}