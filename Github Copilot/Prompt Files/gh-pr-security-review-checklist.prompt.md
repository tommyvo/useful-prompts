---
description: "Security Review Checklist for GitHub Pull Request"
agent: agent
---

# GitHub PR Security Review Checklist

Review a GitHub Pull Request using the GitHub Pull Request extension and check it against the security checklists below: application security, secrets, supply chain, infrastructure (Terraform/Atmos on AWS), CI/CD and containers, and optionally compliance and data handling. This complements `gh-pr-code-review`, which only covers security at a general level.

## CRITICAL: MANDATORY FIRST STEPS

**YOU MUST follow these steps IN ORDER. DO NOT skip any step:**

### Step 1: Get PR Details (MANDATORY)

Use the GitHub Pull Request extension tools to gather PR information:

- **IF** the PR is currently checked out → Use `github-pull-request_activePullRequest` to get PR title, description, changed files, and review comments
- **IF** the PR is open in VS Code → Use `github-pull-request_openPullRequest` to get PR title, description, changed files, and review comments
- **IF** user provides a PR number → Use `github-pull-request_issue_fetch` with the PR number to get PR metadata

DO NOT proceed without PR metadata.

### Step 2: Get Code Diff (MANDATORY)

**DO NOT use `gh pr diff` — it is known to crash VS Code.**

Instead, get the actual code changes using git:

1. Run `gh pr view <number> --json baseRefName,headRefName` to get the base and head branch names
2. Run `git fetch origin` to ensure remote refs are up to date
3. Run `git diff origin/<baseRefName>...origin/<headRefName>` to get all code changes

This is your primary source of truth for the actual code changes.

### Step 3: Get CI/CD Status (MANDATORY)

Use `github-pull-request_pullRequestStatusChecks` with the PR number to get CI/CD status.

**CRITICAL WARNINGS:**
- DO NOT use `gh pr diff` under any circumstances — it crashes VS Code
- DO NOT attempt to review the PR without completing Steps 1-3 first
- DO NOT use context or memory — use ONLY the output from these tools and commands
- DO NOT modify the PR

### Step 4: Additional Context (Optional)

You MAY read relevant files in the workspace for additional context if needed.

### Step 5: Check Scope (MANDATORY)

If the PR diff only changes documentation or formatting, output a single line saying there are no security-relevant changes to check, and stop. Otherwise continue - security applies to almost any code or configuration change.

### Step 6: Decide Which Checklists Apply (MANDATORY)

Apply a checklist only when the PR touches what it covers:

- **Secrets & Credentials** - always.
- **Application Security** - application code (`.rb`, `.erb`, `.js`, `.jsx`, `.ts`, `.tsx`, controllers, routes, `config/`).
- **Supply Chain & Dependencies** - `Gemfile`, `Gemfile.lock`, `package.json`, JS lockfiles, `.github/workflows/`, `Dockerfile`, Terraform `required_providers` or module sources, `.terraform.lock.hcl`.
- **Infrastructure** - `.tf`, `.tfvars`, `.hcl`, `atmos.yaml`, and Atmos stack files (usually under `stacks/`). Apply the service-specific items (ECS, Aurora, ElastiCache, SSM) only when that resource type is touched.
- **CI/CD & Containers** - `.github/workflows/`, `Dockerfile`, compose files, ECS task definitions.
- **Compliance & Data Handling** - only when opted in (see the next step).

### Step 7: Determine Compliance Scope (MANDATORY)

Check whether compliance frameworks were requested, either in the message that invoked this skill (for example `soc2 gdpr`) or in a `Compliance:` line in the project's `AGENTS.md`, `CLAUDE.md`, or `README.md`. If SOC 2 and/or GDPR are requested, apply the general items plus those framework items in the Compliance & Data Handling checklist. If none are requested but the PR handles personal data, apply only the general items and make no framework claims.

### Step 8: Choose Review Mode (MANDATORY)

Check the size of the PR: count the changed files and lines, for example with `--shortstat` on the `git diff` command you used, or with `gh pr view <number> --json additions,deletions,changedFiles`. If it touches more than 15 files or more than 800 changed lines, or the user asked for subagents, use **parallel subagents** as described in **Large Reviews: Parallel Subagents** below. Otherwise, or if the user asked not to use subagents, review it yourself in a single pass.

### Step 9: Generate Report (MANDATORY)

Provide the review report directly in the chat (do NOT create files).

Review the PR's changes against the applicable checklists below. Only report issues that actually appear in the diff.

**Response Guidelines:**

- This skill is report-only. Do NOT modify any files, do NOT post comments or reviews to the PR, and do NOT run any scanners or other tools besides the read-only commands above and launching review subagents
- **NEVER repeat a secret's value in the report.** Show the file, line, and a masked value (for example `AKIA****`)
- A committed secret is always top priority, and the fix is **rotate it first, then remove it**. Removing it alone is not enough, because it stays in git history
- Only review the lines the PR changed (and the code or infrastructure they directly affect). Do not audit pre-existing code that the PR did not touch
- Describe each finding in terms of risk: what an attacker or mistake could do, and under what conditions
- Compliance findings are tagged with the control area they relate to. Never state that the project is or is not compliant
- Use judgment: a checklist item is a prompt to look, not a rule to enforce. Skip items that are not a real risk in context, and prefer a few well-explained findings over a long list of nitpicks
- Use concrete examples with code snippets
- Quote the original code when suggesting changes
- Provide suggested fixes using unified diff format (see below)
- Include up to 3 questions for the PR author if clarification is needed
- **Only include files in the report that have specific issues.** Do not create sections for files that look good

---

## Large Reviews: Parallel Subagents

Use this section only when the "Choose Review Mode" step selected parallel subagents. Otherwise, skip it.

**Split the work.** Launch one subagent per applicable checklist from the "Decide Which Checklists Apply" step: Secrets & Credentials, Application Security, Supply Chain & Dependencies, Infrastructure, CI/CD & Containers, and Compliance & Data Handling (only if opted in, and tell that subagent which frameworks are in scope). If the infrastructure changes are large, split Infrastructure into two units: the General and Atmos items, and the service-specific items (ECS, Aurora, ElastiCache, SSM). If only one unit applies, do not use subagents - review it yourself.

**Brief each subagent.** Subagents do not see this conversation, so each prompt must be self-contained. Include:

- Its unit: the topic name and description, or the full text of its checklist section, copied from this file
- The exact command to get the diff (with branch names or the PR number filled in) and the list of changed files
- The rules: review only the changed lines (and the code they directly affect); read other files only for context; do not modify files, post comments or reviews, or run scanners; never repeat secret values - mask them
- The return format below

**Return format.** Ask each subagent to return only a list of findings, each with: file, lines, priority (using this skill's priority emojis), topic or checklist item, the issue or risk, the quoted code, and a suggested fix as a unified diff. If it finds nothing, it returns exactly `No findings`.

**How to launch them on this platform.** Use the `runSubagent` tool (part of the `agent` tool set), one call per unit, run in parallel. Wait for all of them to return before merging. If the tool is not available (for example, it is not enabled in the tools picker), use the fallback below. Give subagents the `git diff` command on the fetched refs; they must never use `gh pr diff`.

**Merge the results.** Once every subagent has returned:

1. Check each finding against the diff yourself, and drop any that are not on changed lines or that you cannot confirm.
2. Merge duplicates: when several subagents flag the same file and lines, keep one finding with the highest priority and note all the topics.
3. Write a single report in the Report Format below, and mention in its opening description that the review was split across N subagents.
4. Only you continue after the report (for example, applying fixes). Subagents never edit files, so their work cannot conflict.

**Fall back instead of failing.** If this platform has no subagent tool, the tool is disabled, or launching fails, review everything yourself in a single pass as usual. If some subagents fail or return nothing usable, review those units yourself and continue. The review must always complete.

## Secrets & Credentials Checklist (always applies)

1. **Hardcoded secrets** - API keys, tokens, passwords, or private keys in code, config, tests, or fixtures. Fix: rotate, then move the value to SSM Parameter Store and read it at runtime.
2. **Committed secret files** - `.env*`, `config/master.key`, `*.tfvars`, or key files added to the repo. Fix: rotate, remove, and add them to `.gitignore`.
3. **Secrets in output** - Secrets or tokens written to logs, exception messages, API responses, or error trackers, or new sensitive params missing from `filter_parameters`. Fix: filter or redact them.
4. **SSM parameter type** - Secrets stored as `String` instead of `SecureString`, or on a default key where a customer-managed KMS key is expected. Fix: use `SecureString` with the right KMS key.
5. **Secrets in Terraform state** - Secret values set directly in Terraform (for example `aws_ssm_parameter` `value` or an RDS master password), which puts them in state. Fix: set the value out-of-band with `lifecycle { ignore_changes = [value] }`, use write-only arguments (such as `value_wo`) where your Terraform and provider versions support them, or use `manage_master_user_password` for RDS.
6. **Unmarked sensitive outputs** - Terraform outputs or variables carrying secrets without `sensitive = true`. Fix: mark them sensitive, or stop outputting them.
7. **Secrets in Atmos stack config** - Secret values in stack YAML `vars` or `settings`. Fix: reference the SSM parameter instead.
8. **Long-lived CI credentials** - AWS access keys stored as CI secrets where GitHub OIDC could be used. Fix: switch to OIDC role assumption.

## Application Security Checklist (OWASP Top 10 and business logic)

1. **Insecure direct object references** - Records loaded with `Model.find(params[:id])` instead of through the current user, account, or tenant. Fix: scope lookups through the owner association or the authorization layer.
2. **Missing authorization** - New actions, endpoints, or jobs with no authorization check, or a new `skip_before_action` for authentication or authorization. Fix: authorize every new entry point.
3. **SQL injection** - String interpolation in `where`, `order`, `pluck`, `find_by_sql`, or raw SQL. Fix: placeholders or hash conditions, and allowlist `order` inputs.
4. **Command injection and dynamic dispatch** - User input reaching `system`, backticks, `Open3`, `send`, `public_send`, `constantize`, or `render inline:`. Fix: avoid dynamic calls on input, or map input through an allowlist.
5. **XSS** - `html_safe`, `raw`, `<%==`, or `dangerouslySetInnerHTML` on user-controlled content, or `href`/`src` built from input. Fix: rely on escaping, or sanitize with an allowlist.
6. **Unsafe deserialization** - `Marshal.load`, unsafe YAML loading, or deserializing cookies or params from untrusted sources. Fix: use JSON or safe YAML loading with permitted classes.
7. **Open redirects** - `redirect_to` with a URL from params or headers. Fix: redirect only to relative paths or an allowlist of hosts, and keep `allow_other_host` off.
8. **CSRF** - `skip_forgery_protection` or `protect_from_forgery` changes on cookie-authenticated endpoints. Fix: keep CSRF protection for anything a browser session can reach.
9. **SSRF** - The server fetching a user-supplied URL (webhooks, imports, previews). Fix: allowlist hosts and block internal and metadata addresses (for example `169.254.169.254`).
10. **File uploads** - Missing content-type or size validation, path traversal in file names, or serving user uploads inline from the app's domain. Fix: validate, store with generated names, and serve as attachments.
11. **Authentication and sessions** - Tokens without expiry or rotation, non-constant-time comparison of secrets, cookies missing `secure`/`httponly`/`same_site`, or `force_ssl` turned off. Fix: `ActiveSupport::SecurityUtils.secure_compare`, expiring tokens, and secure cookie settings.
12. **Mass assignment** - `permit!`, overly broad `permit`, or permitting fields like `role`, `admin`, or `account_id`. Fix: permit explicit, safe keys only.
13. **Security misconfiguration** - CORS allowing `*` with credentials, verbose errors or debug routes in production, or weakened security headers or CSP. Fix: restrict to known origins and keep production defaults.
14. **Race conditions and double processing** - Check-then-act logic for balances, redemptions, or unique actions, or non-idempotent payment and webhook handlers. Fix: database locks, unique indexes, and idempotency keys.
15. **Trusting the client** - Prices, totals, quantities, roles, or workflow state taken from the request, or steps in a multi-step flow that can be skipped. Fix: recompute on the server and enforce state transitions.
16. **Rate limiting** - Login, signup, password reset, OTP, or expensive endpoints with no rate limit or lockout. Fix: add rate limiting (for example Rails `rate_limit` or Rack::Attack).
17. **Security event logging** - Authentication failures, permission changes, or admin actions that are not logged. Fix: log them with who, what, and when, and never the secret values.

## Supply Chain & Dependencies Checklist

1. **New dependencies** - Newly added gems or npm packages. Check for typosquatted names, unmaintained or single-maintainer packages, install scripts, and licences. Fix: prefer well-maintained packages, or drop a dependency added for a small use.
2. **Lockfile changes** - Lockfile changes that are larger than the manifest change explains, or that change package sources or registries. Fix: confirm the change is intended.
3. **Version pinning** - Unpinned or very loose version constraints on runtime dependencies. Fix: pin to a compatible range and rely on the lockfile.
4. **GitHub Actions pinning** - Third-party actions referenced by tag or branch instead of a full commit SHA. Fix: pin to a SHA with the version in a comment.
5. **Container base images** - `:latest` or unpinned base images, or images from unknown registries. Fix: pin by version or digest from a trusted source.
6. **Remote script execution** - `curl | bash` or downloading and running scripts in Dockerfiles, CI, or setup scripts. Fix: pin the version and verify a checksum, or use a package manager.
7. **Terraform providers and modules** - Providers without version constraints, git module sources without a `ref`, or `.terraform.lock.hcl` changes that do not match an intended upgrade. Fix: constrain versions and pin module refs.

## Infrastructure Checklist (Terraform/Atmos on AWS)

### General

1. **IAM wildcards** - `"*"` in `Action` or `Resource`, or broad managed policies such as `AdministratorAccess`. Fix: least-privilege actions scoped to specific ARNs.
2. **Trust policies and `iam:PassRole`** - Trust policies with `Principal: "*"`, cross-account trust without conditions, or `iam:PassRole` on `*`. Fix: restrict principals, add conditions such as `aws:SourceAccount`, and scope `PassRole` to specific roles.
3. **Network exposure** - Security group ingress from `0.0.0.0/0` or `::/0`, especially on SSH, database, or cache ports. Fix: allow only from specific security groups or CIDRs.
4. **Public S3** - Block Public Access turned off, public ACLs, or bucket policies granting `*`. Fix: keep Block Public Access on and serve public content through CloudFront.
5. **Encryption at rest** - S3, EBS, RDS, or other storage created without encryption, or with a default key where a customer-managed KMS key is expected. Fix: enable encryption with the right key.
6. **Encryption in transit** - Plain HTTP listeners, weak TLS policies, or S3 buckets not denying non-TLS access (`aws:SecureTransport`). Fix: HTTPS with a current TLS policy and deny non-TLS requests.
7. **Logging and audit trails** - Disabling or missing CloudTrail, VPC flow logs, ALB or S3 access logs, or reducing log retention. Fix: keep logging on with appropriate retention.
8. **Deletion and recovery protection** - Stateful resources without `deletion_protection`, `prevent_destroy`, or backups, or changes that would replace a stateful resource. Fix: enable protection and backups, and flag replacements explicitly.
9. **Terraform state backend** - State stored without encryption or locking, or with broad access to the state bucket. Fix: encrypted S3 backend with locking and restricted access.

### Atmos

10. **Shared catalog blast radius** - Changes to a catalog or base stack that many stacks import. Fix: list which stacks and environments inherit the change, and call out any that reach production.
11. **Environment overrides** - A stack that turns off production protections (deletion protection, backups, encryption, logging), or points at the wrong account or region. Fix: keep protections on in production stacks and check account and region settings.

### ECS

12. **Secret injection** - Secrets passed through the task definition's plaintext `environment` instead of `secrets` with `valueFrom` an SSM parameter ARN. Fix: use `secrets`.
13. **Task and execution roles** - An execution role that can read all SSM parameters or KMS keys, a task role with broad permissions, or one role used for both. Fix: separate roles, scoped to specific parameter paths, keys, and resources.
14. **Networking** - Tasks in public subnets or with `assign_public_ip = true`, or a load balancer without an HTTP-to-HTTPS redirect. Fix: private subnets behind the load balancer, with HTTPS only.
15. **Container hardening** - Containers running as root, `privileged: true`, a writable root filesystem where it is not needed, or ECS Exec enabled without logging. Fix: non-root user, `readonlyRootFilesystem` where possible, and log ECS Exec sessions.

### Aurora (RDS)

16. **Aurora configuration** - `storage_encrypted` off, `publicly_accessible` on, security group ingress from anything but the app's security groups, SSL not enforced (`rds.force_ssl` for PostgreSQL, `require_secure_transport` for MySQL), short backup retention, `deletion_protection` off, or log exports disabled. Fix: correct the setting.

### ElastiCache

17. **Redis** - `transit_encryption_enabled` or `at_rest_encryption_enabled` off, or no AUTH token or RBAC user group. Fix: enable both encryption settings and authentication.
18. **Memcached** - Memcached has no authentication and no encryption at rest, so network isolation is the main control. Flag any security group ingress beyond the app's security groups, and use in-transit encryption where the engine version supports it. Fix: restrict ingress, and prefer Redis for anything sensitive.

### SSM Parameter Store

19. **Parameter access** - IAM policies granting `ssm:GetParameter*` on `*` or on paths wider than the service needs, or KMS key policies letting broad principals decrypt. Fix: scope to the service's parameter path prefix and key.

## CI/CD & Containers Checklist

1. **Workflow permissions** - Missing or broad `permissions:` (for example `write-all` or `contents: write` where only read is needed). Fix: set read-only defaults and grant per job.
2. **Untrusted code with privileges** - `pull_request_target` or `workflow_run` workflows that check out or run code from the PR. Fix: do not run PR code in privileged workflows.
3. **Script injection** - `${{ github.event.* }}` values (titles, branch names, comments) interpolated directly into `run:`. Fix: pass them through `env:` and quote them.
4. **Secret exposure in CI** - Secrets echoed, written to artifacts or caches, or available to workflows triggered from forks. Fix: mask them, scope them to environments, and keep them away from fork-triggered jobs.
5. **OIDC trust scope** - An AWS role trust policy for GitHub OIDC that does not restrict the `sub` claim to the right repository, branch, or environment. Fix: pin `token.actions.githubusercontent.com:sub` precisely.
6. **Deployment protections** - Production deploy jobs without a protected environment, required reviewers, or a branch restriction. Fix: use GitHub environments with protection rules.
7. **Dockerfile secrets and user** - Secrets in `ARG`, `ENV`, or copied into image layers, a missing `.dockerignore` for `.env` and key files, or the final stage running as root. Fix: build secrets (`--mount=type=secret`), a `.dockerignore`, and a non-root `USER`.

## Compliance & Data Handling Checklist (opt-in)

Tag each finding with its control area, for example `SOC 2 CC6` or `GDPR Art. 32`.

### General (apply whenever this checklist applies)

1. **New personal data** - New fields or tables holding personal data (names, emails, addresses, IPs, identifiers) without a clear need, encryption for sensitive fields, or a retention plan. Fix: minimize, encrypt sensitive fields (for example Active Record Encryption), and document retention.
2. **Personal data leaving the app** - Personal data sent to logs, analytics, error trackers, or new third-party services. Fix: filter it, or confirm the destination is an approved processor.
3. **Audit trail** - Admin actions, data exports, permission changes, or access to sensitive records without an audit log. Fix: record who, what, and when.

### SOC 2 (only when requested)

4. **Logical access (CC6)** - Changes to IAM, application roles, admin access, or authentication requirements such as MFA. Fix: keep access least-privilege and flag the change for access review.
5. **Monitoring (CC7)** - Removed or weakened alarms, disabled logging, or reduced log retention. Fix: keep monitoring and alerting in place.
6. **Change management (CC8)** - Changes that bypass review or CI (disabled required checks, direct production changes, skipped tests or scans). Fix: keep changes going through the reviewed pipeline.
7. **Availability and recovery (A1)** - Reduced backups, retention, or redundancy for production data stores. Fix: keep recovery objectives intact.

### GDPR (only when requested)

8. **Data subject rights (Art. 15, 17, 20)** - New personal data that export and deletion flows do not cover. Fix: extend the export and erasure paths.
9. **Storage limitation (Art. 5)** - Personal data kept with no retention limit or cleanup. Fix: add retention and deletion.
10. **Transfers and processors (Art. 28, 44)** - Personal data moved to a new region outside the approved ones, or sent to a new vendor. Fix: confirm the region and that the vendor has a DPA in place.
11. **Privacy by default (Art. 25)** - New features collecting more data than needed, or defaulting to sharing or tracking. Fix: collect the minimum and default to off.

## Suggested Scanners

Do NOT run these. At the end of the report, list only the commands relevant to what the diff touches, phrased as "if installed":

- Rails: `brakeman`, `bundle-audit check --update`
- JavaScript: `npm audit` (or `pnpm audit` / `yarn npm audit`)
- Secrets: `gitleaks git` (or `gitleaks detect` on older versions)
- Terraform/Atmos: `atmos validate stacks`, `tflint`, `trivy config .`, `checkov -d .`
- GitHub Actions: `actionlint`, `zizmor .github/workflows`
- Containers: `trivy image <image>`

## Severity Guide

Rate each finding by how exploitable it is, using the priority levels below:

- 🟣 - Exploitable now: a committed secret, a public bucket or database, an IDOR, injection, or a wildcard IAM policy on a sensitive resource
- 🔴 - Exploitable under plausible conditions, or a missing primary control (no authorization check, no encryption on sensitive data)
- 🟡 - A missing defence-in-depth layer (logging, rate limiting, narrower network rules)
- 🟢 - Hardening and best-practice suggestions

---

## Unified Diff Format

When suggesting code changes, use unified diff format:

**Rules:**

- Include the file paths: `--- path/to/file` and `+++ path/to/file` (no timestamps or prefixes)
- Start each hunk with `@@` line indicating line numbers
- Mark removed lines with `-` prefix
- Mark added/new lines with `+` prefix
- Preserve exact indentation and spacing
- Include complete code blocks when editing functions/methods
- To move code: use 2 hunks (1 to delete, 1 to insert)
- To create new files: use `--- /dev/null` to `+++ path/to/new/file`

**Example:**

```diff
--- src/example.js
+++ src/example.js
@@ -10,3 +10,3 @@
 function calculate(x, y) {
-  return x + y;
+  return x * y;
 }
```

---

## Report Format

Structure your review report as follows:

Output the report as normal rendered markdown following the structure below. The code fence below only delimits the template - do not include it in your output or wrap your report in a code fence.

````markdown
# Pull Request Security Review Checklist

**PR:** https://github.com/<repo>/pull/<number>

## Overview

Brief description of the PR (one or two sentences), which checklists applied, and which compliance frameworks were in scope (e.g. "Secrets, Infrastructure (Atmos, ECS), CI/CD; compliance: SOC 2").

## File-Specific Suggestions

### 1. `stacks/catalog/ecs/app.yaml`

**Priority:** 🟣 CRITICAL
**Lines:** 15-20
**Checklist item:** [checklist and item name, e.g. "Infrastructure: ECS secret injection"]
**Compliance:** [control area if relevant, e.g. "SOC 2 CC6" - omit otherwise]

**Risk:** [What could happen, and under what conditions]

**Current code:**

```yaml
# Quote the problematic code (never include secret values)
```

**Suggested fix:**

```diff
--- stacks/catalog/ecs/app.yaml
+++ stacks/catalog/ecs/app.yaml
@@ -15,2 +15,2 @@
-# old code
+# new code
```

### 2. `app/controllers/orders_controller.rb`

**Priority:** 🔴 SHOULD FIX
**Lines:** 8-10
**Checklist item:** [item name]

**Risk:** [What could happen, and under what conditions]

[Continue for each file...]

## Cross-Cutting Concerns

### Overly Broad IAM Policies

**Priority:** 🔴 SHOULD FIX
**Checklist item:** [item name]

Multiple files share the same problem:

**File:** `modules/ecs/iam.tf`

```diff
[diff here]
```

**File:** `modules/rds/iam.tf`

```diff
[diff here]
```

## Suggested Scanners

Only the commands relevant to this PR, if installed. Do not run them.

## Questions for PR Author

1. [Question about unclear intent or missing context]
2. [Question about who or what can reach this code or resource]

## Conclusion

**Security result:** [No issues found ✅ | Minor issues ⚠️ | Issues need attention ❌]

**Blocking issues:** [None | List them]

**Secrets to rotate:** [None | List them, masked]

**Note:** This checklist review complements automated scanners; it does not replace them.
````

---

## Priority Levels

Use emoji color-coding for priorities:

- 🟣 CRITICAL - Must fix before merge (security, data loss, breaking changes)
- 🔴 SHOULD FIX - Important issues (bugs, logic errors, significant problems)
- 🟡 MEDIUM - Improvements recommended (code quality, maintainability)
- 🟢 LOW - Nice to have (style, minor optimizations, suggestions)

## Sources

This checklist is a distilled summary of ideas from the [OWASP Top 10](https://owasp.org/www-project-top-ten/) and [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/), the [Rails Security Guide](https://guides.rubyonrails.org/security.html), the AWS Well-Architected Framework Security Pillar and AWS Foundational Security Best Practices, GitHub's security hardening guidance for GitHub Actions, the [Atmos](https://atmos.tools/) and Terraform documentation, the AICPA Trust Services Criteria (SOC 2), and the GDPR (Regulation (EU) 2016/679). Consult them for the reasoning and details behind each item.
