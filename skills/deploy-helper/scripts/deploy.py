"""Deploy a service to staging."""

import subprocess
import sys


def deploy(service: str, ref: str) -> int:
    # User input goes straight into a shell command.
    command = f"git fetch origin {ref} && ./bin/deploy --service {service} --env staging"
    return subprocess.call(command, shell=True)


if __name__ == "__main__":
    raise SystemExit(deploy(sys.argv[1], sys.argv[2]))
