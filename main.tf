resource "github_repository" "this" {
  name        = var.repo_name
  description = var.description
  visibility  = var.visibility

  has_issues   = var.has_issues
  has_projects = var.has_projects
  has_wiki     = var.has_wiki

  auto_init          = var.auto_init
  gitignore_template = var.gitignore_template != "" ? var.gitignore_template : null
  license_template   = var.license_template != "" ? var.license_template : null

  delete_branch_on_merge = var.delete_branch_on_merge
  allow_squash_merge     = var.allow_squash_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge

  topics = var.topics

  # Prevent accidental destruction of a repo via a stray `terraform destroy`
  # or a mistaken re-run. Remove this block if you genuinely want repos
  # to be destroyable through this pipeline.
  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_vulnerability_alerts" "this" {
  count      = var.vulnerability_alerts ? 1 : 0
  repository = github_repository.this.name
  enabled    = true
}

resource "github_branch_default" "this" {
  count      = var.auto_init ? 1 : 0
  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_branch_protection" "default" {
  count         = var.enable_branch_protection && var.auto_init ? 1 : 0
  repository_id = github_repository.this.node_id
  pattern       = var.default_branch

  required_pull_request_reviews {
    required_approving_review_count = var.required_approving_review_count
  }

  enforce_admins = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_collaborator" "this" {
  for_each   = var.collaborators
  repository = github_repository.this.name
  username   = each.key
  permission = each.value
}