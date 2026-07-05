# Contributing to swissknife

Thank you for your interest in contributing! We want to keep this project high-quality and easy to use.

## How to Contribute

1. **Fork the repo** and create your branch from `master`.
2. **If you've added code**:
   - Ensure it's POSIX compliant where possible (use `sh` over `bash` extensions).
   - Add/update tests in `jsk-bash-test.bats`.
   - Run `shellcheck` on your scripts.
3. **Ensure the license header** is present in new scripts:
   ```bash
   # license     : Apache License 2.0
   ```
4. **Submit a Pull Request** with a clear description of the changes.

## Development Environment

You can use the provided `Vagrantfile` to spin up a consistent Debian development environment:

```bash
vagrant up
vagrant ssh
```

## Code Standards
- Use lowercase for filenames and hyphens instead of spaces.
- Keep scripts focused on a single task.
- Document functions and variables clearly.
