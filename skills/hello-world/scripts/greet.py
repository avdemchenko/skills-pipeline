"""Print a greeting for the given name."""

import sys


def main() -> int:
    name = " ".join(sys.argv[1:]).strip() or "world"
    print(f"Hello, {name}!")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
