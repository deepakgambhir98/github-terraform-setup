terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "../terraform-state/terraform.tfstate"
  }
}

provider "github" {
  # Auth via GITHUB_TOKEN / GITHUB_APP_* env vars (set in the Actions workflow).
  # Do NOT hardcode tokens here.
  owner = var.github_owner
}


