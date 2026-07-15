variable "repo_name" {
  description = "Name of the GitHub repository to create. This is the ONLY value you need to supply."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]{1,100}$", var.repo_name))
    error_message = "repo_name must be 1-100 chars: letters, numbers, dots, hyphens, underscores only."
  }
}

variable "github_owner" {
  description = "GitHub org or user that owns the repo. Defaults to the token's org via GITHUB_OWNER env var."
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility: public, private, or internal."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be one of: public, private, internal."
  }
}

variable "description" {
  description = "Repository description."
  type        = string
  default     = "Repository provisioned via Terraform."
}

variable "has_issues" {
  type    = bool
  default = true
}

variable "has_projects" {
  type    = bool
  default = false
}

variable "has_wiki" {
  type    = bool
  default = false
}

variable "auto_init" {
  description = "Whether to create an initial commit (README) so the default branch exists immediately."
  type        = bool
  default     = true
}

variable "gitignore_template" {
  description = "Optional .gitignore template name (e.g. 'Node', 'Python'). Leave empty to skip."
  type        = string
  default     = ""
}

variable "license_template" {
  description = "Optional license keyword (e.g. 'mit', 'apache-2.0'). Leave empty to skip."
  type        = string
  default     = ""
}

variable "default_branch" {
  description = "Default branch name."
  type        = string
  default     = "main"
}

variable "delete_branch_on_merge" {
  type    = bool
  default = true
}

variable "allow_squash_merge" {
  type    = bool
  default = true
}

variable "allow_merge_commit" {
  type    = bool
  default = false
}

variable "allow_rebase_merge" {
  type    = bool
  default = false
}

variable "vulnerability_alerts" {
  description = "Enable Dependabot vulnerability alerts."
  type        = bool
  default     = true
}

variable "topics" {
  description = "List of topics/tags to apply to the repo."
  type        = list(string)
  default     = []
}

variable "enable_branch_protection" {
  description = "Whether to protect the default branch (requires the branch to already exist, i.e. auto_init = true)."
  type        = bool
  default     = false
}

variable "required_approving_review_count" {
  type    = number
  default = 1
}

variable "collaborators" {
  description = "Optional map of GitHub usernames to permission (pull, triage, push, maintain, admin)."
  type        = map(string)
  default     = {}
}


