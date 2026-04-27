terraform {
  backend "local" {
    path = "/home/bob/terraform/env/dev/terraform.tfstate"
  }
}