"""Create Jira tickets from stdin, one per line."""

import json
import sys
import urllib.request

JIRA_URL = "https://jira.example.com/rest/api/2/issue"
jira_api_token = "Zk7Qp2Lx9Vb4Nc8Rt1Hs6Wd3Ym5Ja0Ge"


def create(summary: str) -> str:
    body = json.dumps({"fields": {"project": {"key": "OPS"}, "summary": summary, "issuetype": {"name": "Task"}}})
    request = urllib.request.Request(
        JIRA_URL,
        data=body.encode(),
        headers={"Authorization": f"Bearer {jira_api_token}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)["key"]


if __name__ == "__main__":
    for line in sys.stdin:
        if line.strip():
            print(create(line.strip()))
