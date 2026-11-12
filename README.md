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
3. **State location**: local Terraform runs store state at
  `../terraform-state/terraform.tfstate`, outside this project directory.
  GitHub Actions uploads the runner's state as a `terraform-state` artifact
  with 7-day retention. Download it from the workflow run's Artifacts section.
  It is a snapshot for download only and is not restored by later runs. Treat
  it as sensitive; anyone with access to that workflow run can download it.
  For persistent CI state, configure a remote backend such as Terraform Cloud
  or S3 instead.

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

If you already initialized Terraform with a different backend, run
`terraform init -migrate-state` to move its state to the configured path.

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
- **Local state outside the project**: the local backend stores state in the
  sibling `terraform-state` directory. Use a remote backend for persistent CI
  state across GitHub Actions runs.

## Extending

- To create many repos at once, wrap `github_repository.this` in a `for_each`
  over a variable map, and change the workflow input to a comma-separated
  list or JSON array.
- To pre-populate files (e.g. a standard `.github/CODEOWNERS`), add a
  `github_repository_file` resource referencing `github_repository.this.name`.


