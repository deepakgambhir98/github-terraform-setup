terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Remote state is strongly recommended for a "robust and scalable" setup,
  # especially when this is triggered repeatedly from CI (GitHub Actions runners
  # are ephemeral and have no local state between runs).
  #
  # Uncomment and configure ONE of the backends below. S3 example shown;
  # swap for Terraform Cloud / Azure / GCS as needed.
  #
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "github-repos/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "github" {
  # Auth via GITHUB_TOKEN / GITHUB_APP_* env vars (set in the Actions workflow).
  # Do NOT hardcode tokens here.
  owner = var.github_owner
}


