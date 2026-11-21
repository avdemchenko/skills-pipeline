# Skills Pipeline

[![Skill checks](https://github.com/avdemchenko/skills-pipeline/actions/workflows/skill-checks.yml/badge.svg?branch=main)](https://github.com/avdemchenko/skills-pipeline/actions/workflows/skill-checks.yml)
[![Semgrep](https://github.com/avdemchenko/skills-pipeline/actions/workflows/semgrep.yml/badge.svg?branch=main)](https://github.com/avdemchenko/skills-pipeline/actions/workflows/semgrep.yml)

The company's central repository of AI agent skills, with an automated security and quality gate.
Every skill follows the open [Agent Skills specification](https://agentskills.io/) and works with
Claude Code, Codex, Copilot CLI and other compatible agents.

Agent skills run with the agent's permissions: they can read files, run scripts and reach the
network. A skill gets onto `main` only after it passes the automated checks below and a review by
a code owner.

## Contents

- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Adding a skill](#adding-a-skill)
- [Running checks locally](#running-checks-locally)
- [Skill policies](#skill-policies)
- [Handling findings](#handling-findings)
- [Maintaining the pipeline](#maintaining-the-pipeline)

## How it works

```
pull request ──┬──> Skill checks (SkillEvaluator Tier 1) ──┐
               │                                           ├──> code owner review ──> merge to main
               └──> Semgrep (registry rulesets) ───────────┘
```

| Check | Workflow | What it covers |
|---|---|---|
| **Tier 1 scan** | [`skill-checks.yml`](.github/workflows/skill-checks.yml) | [NVIDIA SkillEvaluator](https://github.com/NVIDIA/SkillEvaluator) v1.0.1 in a pinned container. Runs 11 checks: schema, version, security ([SkillSpector](https://github.com/NVIDIA/SkillSpector): prompt injection, data exfiltration, privilege escalation, supply chain, MCP tool poisoning), PII, license, code integrity (Bandit, Semgrep, Gitleaks), Unicode smuggling, quality score, script lint and agent harness compatibility. |
| **Semgrep scan** | [`semgrep.yml`](.github/workflows/semgrep.yml) | Semgrep 1.182.0 with the `p/security-audit`, `p/secrets` and `p/command-injection` registry rulesets over all bundled scripts. This is broader than the policy built into SkillEvaluator. |

Design principles:

- **No LLM keys, no data egress.** All checks are static. Skill content is never sent to a model provider.
- **Fail closed.** A finding, a scanner crash or an incomplete scan fails the check.
- **Pinned supply chain.** Every action, reusable workflow and container image is pinned to a commit SHA or a `sha256` digest. Nothing resolves `main` or `latest` at runtime.
- **Least privilege.** Workflows run with `contents: read` and never check out with persisted credentials.

On pull requests SkillEvaluator scans only the skills that changed. On `main` it scans every skill.

To see the gate in action, read the [policy violation demos](docs/policy-violation-demos.md): six
pull requests with intentionally non-compliant skills, each blocked by the pipeline.

## Repository layout

```
.
├── .github/
│   ├── workflows/
│   │   ├── skill-checks.yml      # SkillEvaluator Tier 1 gate
│   │   └── semgrep.yml           # Semgrep gate
│   ├── CODEOWNERS
│   └── pull_request_template.md
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md              # required: frontmatter and instructions
│       ├── scripts/              # optional: helper scripts the skill runs
│       └── references/           # optional: extra docs loaded on demand
├── templates/
│   └── skill/SKILL.md            # starting point for new skills
├── scripts/
│   └── check.sh                  # runs both gates locally
├── CONTRIBUTING.md
└── SECURITY.md
```

## Adding a skill

```bash
cp -R templates/skill skills/my-skill
# Edit skills/my-skill/SKILL.md: set name (must match the folder) and description
./scripts/check.sh skills/my-skill
```

Then open a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for naming rules, the review
process and the authoring checklist.

## Running checks locally

Requirements: [uv](https://docs.astral.sh/uv/) and [Semgrep](https://semgrep.dev/docs/getting-started/)
(`brew install semgrep` or `pipx install semgrep`).

```bash
./scripts/check.sh                    # all skills
./scripts/check.sh skills/my-skill    # one skill
```

The script runs the same tool versions and rulesets as CI. Local reports land in `reports/`,
which git ignores.

## Skill policies

| Rule | Reason |
|---|---|
| `name` in frontmatter matches the folder name, lowercase and hyphenated | Required by the spec and by agent loaders |
| `description` says what the skill does **and** when to use it, in at most 1,024 characters | Longer descriptions get truncated or rejected by some agents |
| No `license: Proprietary`, `Commercial`, `Confidential` or `All-Rights-Reserved` | Blocked by the SkillEvaluator default policy. Leave `license` unset for internal skills. |
| No secrets, tokens, internal hostnames or customer data | Caught by Gitleaks, SkillSpector and the PII check |
| No network calls or shell execution unless the skill's purpose requires it | Flagged as exfiltration or command injection risk |
| Dependencies pinned to exact versions | Unpinned dependencies fail the hygiene check |
| Minimum quality score is 70/100 | Enforced by `min-score` in `skill-checks.yml` |

## Handling findings

1. **Open the report.** Each failed run uploads a report artifact: HTML and JSON from SkillEvaluator, SARIF from Semgrep. Download it from the run's *Summary* page.
2. **Fix the root cause first.** Most findings point at a real problem: `shell=True`, string-built commands, a hard-coded token.
3. **Suppress only a confirmed false positive,** next to the code, with a reason:
   - Semgrep: `# nosemgrep: <rule-id> -- <why this is safe>`
   - Gitleaks: `# gitleaks:allow` for an intentional test token, or an entry in `.gitleaksignore` at the skill root
4. Every suppression needs code owner approval in the pull request.

## Maintaining the pipeline

**Upgrading SkillEvaluator.** Take the workflow commit SHA and image digest from the new release's
`ci/bundles/<version>/release.json` in
[NVIDIA/SkillEvaluator](https://github.com/NVIDIA/SkillEvaluator/tree/main/ci/bundles). Update
both in `skill-checks.yml`, and bump the version in `scripts/check.sh` to match.

**Upgrading Semgrep or GitHub Actions.** Pin the new version or commit SHA, and keep the version
tag in a trailing comment. Change `semgrep.yml` and `scripts/check.sh` together.

**Branch protection on `main`.** Require a pull request with code owner review, and require the
`Tier 1 scan` and `Semgrep scan` status checks.

## Security

To report a vulnerability in a skill or in the pipeline, see [SECURITY.md](SECURITY.md).
