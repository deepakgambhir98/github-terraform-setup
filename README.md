# Terraform: GitHub Repository Factory

Create GitHub repositories by supplying **only a name** — either via the GitHub
Actions workflow (`workflow_dispatch`) or locally with Terraform.

## Structure

```
terraform-github-repo/
├── versions.tf                    # provider + backend config
├── variables.tf                   # repo_name is the only required input
├── main.tf                        # github_repository + optional branch protection/collaborators
├── outputs.tf                     # clone URLs, html URL, etc.
├── terraform.tfvars.example
└── .github/workflows/create-repo.yml   # workflow_dispatch, input: repo
```

## One-time setup

1. **Create a GitHub token** with `repo` (and `admin:org` if creating in an org)
   scope — a fine-grained PAT or a GitHub App installation token both work.
2. **Add repo secrets** (Settings → Secrets and variables → Actions):
   - `GH_ADMIN_TOKEN` — the token above.
   - `GH_OWNER` — the org or user that should own new repos.
3. **Set up remote state** (recommended once you're running this from CI more
   than a few times). Uncomment the `backend` block in `versions.tf` and point
   it at an S3 bucket + DynamoDB lock table, Terraform Cloud workspace, or
   equivalent. Without this, each Action run starts from a blank state file
   and won't know about repos created in previous runs.

## Usage — GitHub Actions

1. Go to **Actions → Create GitHub Repository → Run workflow**.
2. Enter the repo name in the `repo` field.
3. Run. Terraform plans and applies automatically, and prints the new repo's
   clone URLs in the job output.

## Usage — locally

```bash
cd terraform-github-repo
terraform init
terraform apply -var="repo_name=my-new-repo"
```

## Design notes (why this is "robust and scalable")

- **Single required input**: everything else (visibility, branch rules,
  merge strategy, topics, etc.) has a sensible default in `variables.tf`, but
  can be overridden with `-var` / `TF_VAR_*` without touching code.
- **Validation**: `repo_name` and `visibility` are validated before any API
  call is made, so typos fail fast in `terraform plan`.
- **Idempotent & safe**: `lifecycle { prevent_destroy = true }` stops an
  accidental `terraform destroy` (or a bad state diff) from deleting a repo
  through this pipeline.
- **Concurrency-safe CI**: the workflow uses a `concurrency` group so two
  simultaneous runs can't corrupt the same state file.
- **Extensible**: branch protection and collaborator management are already
  wired up (`enable_branch_protection`, `collaborators` variables) — turn
  them on per-repo without editing `main.tf`.
- **Remote state ready**: swap in any Terraform backend for team-safe,
  multi-run state instead of local `.tfstate` (which doesn't persist between
  ephemeral Actions runners anyway).

## Extending

- To create many repos at once, wrap `github_repository.this` in a `for_each`
  over a variable map, and change the workflow input to a comma-separated
  list or JSON array.
- To pre-populate files (e.g. a standard `.github/CODEOWNERS`), add a
  `github_repository_file` resource referencing `github_repository.this.name`.


