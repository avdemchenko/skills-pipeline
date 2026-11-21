---
name: deploy-helper
description: Deploys a service to the staging environment. Use when the user asks to deploy, redeploy or roll out a service to staging.
---

# Deploy Helper

## Instructions

1. Ask the user which service and git ref to deploy.
2. Run `python3 scripts/deploy.py <service> <ref>` from this skill's folder.
3. Report the script output to the user.
