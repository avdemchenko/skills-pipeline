# Contributing

Thanks for contributing a skill. This guide covers authoring, local checks and review.

## Workflow

1. Create a branch: `git checkout -b skill/<skill-name>`.
2. Copy the template: `cp -R templates/skill skills/<skill-name>`.
3. Write the skill (see [Authoring checklist](#authoring-checklist)).
4. Run `./scripts/check.sh skills/<skill-name>` until it passes.
5. Open a pull request and fill in the template.
6. Wait for both required checks to go green and for a code owner to approve.

One skill per pull request keeps the review focused and the scan fast.

## Naming

- Folder name and the frontmatter `name` must match exactly.
- Lowercase letters, digits and hyphens only, at most 64 characters: `pdf-report-builder`, not `PDF_Report_Builder`.
- Name the capability, not the team: `invoice-reconciliation`, not `finance-team-helper`.

## Authoring checklist

**Frontmatter**
- [ ] `name` matches the folder.
- [ ] `description` states what the skill does and when the agent should use it, in at most 1,024 characters.
- [ ] No `license` field, or an allowed SPDX identifier. Internal skills leave it unset.

**Instructions**
- [ ] `SKILL.md` stays short. Move long reference material to `references/` and link to it.
- [ ] Steps are concrete and ordered. The agent should not have to guess intent.
- [ ] Nothing tells the agent to skip confirmations, hide its actions or ignore user or system instructions.

**Scripts**
- [ ] Every script is needed, readable and not obfuscated or minified.
- [ ] No `shell=True`, `eval` or `exec`, and no commands built by string concatenation.
- [ ] Network access only where the skill's purpose requires it, to documented hosts.
- [ ] No writes outside the working directory the agent was given.
- [ ] Dependencies pinned to exact versions.

**Data**
- [ ] No secrets, tokens, internal URLs, customer data or personal data, including in examples and test fixtures.

## Review

Code owners review every pull request, with extra scrutiny for:

- New or changed files under `scripts/`: anything the agent executes.
- New network destinations, file system writes or permission requests.
- Any suppression comment (`nosemgrep`, `gitleaks:allow`) or `.gitleaksignore` entry.
- Changes to `.github/`: workflows, CODEOWNERS and templates.

A green pipeline is necessary but not sufficient. Static scanners cannot prove intent, and the
reviewer is the last line of defense.

## Changing an existing skill

Bump `version` in `metadata`, if the skill declares one, whenever its behavior changes. Describe
the behavior change in the pull request, not only the diff.
