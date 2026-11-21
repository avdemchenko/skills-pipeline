# Security Policy

## Scope

This policy covers:

- Skills in `skills/`: malicious or unsafe instructions, scripts or dependencies.
- The pipeline in `.github/`: anything that lets an unsafe skill bypass the checks, or exposes repository secrets.

## Reporting a vulnerability

**Do not open a public issue or pull request.**

Report privately through GitHub's
[private vulnerability reporting](https://github.com/avdemchenko/skills-pipeline/security/advisories/new)
(*Security → Report a vulnerability*). Include:

- The affected skill or workflow, and the commit SHA.
- What an attacker can achieve and what it requires.
- Reproduction steps or a minimal proof of concept.

## If a malicious skill reached `main`

1. Revert the merge commit right away. Do not wait for the root cause.
2. Tell users of the skill to remove it locally and to rotate any credentials it could reach.
3. Find out why the checks and the review missed it, and add a detection: a Semgrep rule, a test case or a checklist item.

## Pipeline security guarantees

- Workflows trigger on `pull_request`, never `pull_request_target`. Code from a fork runs without repository secrets.
- Workflow tokens are read-only (`contents: read`). Checkout does not persist credentials.
- All actions, reusable workflows and container images are pinned to immutable SHAs or digests.
- No checks send skill content to external LLM providers.
