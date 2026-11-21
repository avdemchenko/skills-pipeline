#!/usr/bin/env bash
# Run the same gates as CI, locally.
#   ./scripts/check.sh                  # every skill under skills/
#   ./scripts/check.sh skills/my-skill  # one or more skill folders
#
# Keep versions in sync with .github/workflows/skill-checks.yml and semgrep.yml.
set -euo pipefail

SKILLEVALUATOR_VERSION="1.0.1"
SEMGREP_RULESETS=(p/security-audit p/secrets p/command-injection)

cd "$(dirname "$0")/.."

for tool in uvx semgrep; do
  command -v "$tool" >/dev/null || { echo "error: '$tool' not found. See README > Running checks locally." >&2; exit 2; }
done

if [ "$#" -gt 0 ]; then
  targets=("$@")
else
  targets=()
  for dir in skills/*/; do
    [ -f "${dir}SKILL.md" ] && targets+=("${dir%/}")
  done
fi
[ "${#targets[@]}" -gt 0 ] || { echo "error: no skills found" >&2; exit 2; }

status=0

echo "==> SkillEvaluator ${SKILLEVALUATOR_VERSION} (Tier 1)"
for skill in "${targets[@]}"; do
  echo "--- ${skill}"
  uvx --python 3.13 "skillevaluator==${SKILLEVALUATOR_VERSION}" validate "$skill" --tiers 1 || status=1
done

echo "==> Semgrep $(semgrep --version)"
config_args=()
for ruleset in "${SEMGREP_RULESETS[@]}"; do config_args+=(--config "$ruleset"); done
semgrep scan "${targets[@]}" "${config_args[@]}" --metrics=off --error --quiet || status=1

if [ "$status" -eq 0 ]; then echo "==> All checks passed"; else echo "==> Checks failed" >&2; fi
exit "$status"
