# Company skills

Каждый скилл — папка в `skills/<name>/` с `SKILL.md` ([Agent Skills spec](https://agentskills.io/)).

## Проверки на каждый PR

| Workflow | Что делает |
|---|---|
| `skill-checks.yml` | Официальный SkillEvaluator Tier 1 (v1.0.1): SkillSpector, Semgrep (политика SkillEvaluator), Gitleaks, Bandit, pip-audit, качество, схема, PII, Unicode, лицензия, совместимость с агентами. На PR — только изменённые скиллы. Без LLM-ключа. |
| `semgrep.yml` | Semgrep со стандартными наборами `p/security-audit`, `p/secrets`, `p/command-injection` по всем `skills/`. Любая находка — красный check. SARIF лежит в артефактах запуска. |

## Локальный прогон

```bash
uvx --python 3.13 skillevaluator==1.0.1 validate skills/<name> --tiers 1
semgrep scan skills --config p/security-audit --config p/secrets --config p/command-injection --metrics=off --error
```

## Правила

- **Не указывайте `license: Proprietary`** (или Commercial/Confidential) в `SKILL.md`: дефолтная политика SkillEvaluator их блокирует. Оставьте поле пустым.
- Ложное срабатывание Semgrep — `# nosemgrep: <rule-id>` на строке с комментарием, почему это безопасно.
- Версии инструментов закреплены по SHA/digest. Обновлять — из `release.json` нового бандла SkillEvaluator, никогда не `main`/`latest`.

## Включить блокировку merge

Settings → Branches → правило для `main` → Require status checks: **Tier 1 scan** и **Semgrep scan**.
