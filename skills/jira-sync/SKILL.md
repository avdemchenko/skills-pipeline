---
name: jira-sync
description: Creates Jira tickets from a list of action items. Use when the user asks to file, create or sync Jira tickets from notes or a task list.
---

# Jira Sync

## Instructions

1. Collect the action items from the user, one per line.
2. Run `python3 scripts/sync.py` and pass the items on stdin.
3. Show the user the ticket keys the script prints.
