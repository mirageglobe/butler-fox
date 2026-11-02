# AGENTS.md

agent briefing for the `butler-fox` repository.

---

## what this project is

opinionated system helper CLI (`fox`) for local machine management on macOS and debian/ubuntu. fights forgetfulness — a curated, distributable reference and command runner for tools developers use daily.

see [SPEC.md](SPEC.md) for architecture, component breakdown, and roadmap.

---

## file ownership

| file | owns |
| :--- | :--- |
| `src/fox-sh/fox.sh` | canonical bash CLI — menus, helpers, OS detection, all commands |
| `src/fox-sh/.fox.bash` | shell profile fragment sourced on install to put `fox` on `$PATH` |
| `test/fox.sh.test` | bats test suite for `fox.sh` |
| `dist/` | build output — do not edit directly; populated by `make deploy` |
| `Dockerfile` | sandbox image with curl, bats, shellcheck pre-installed |
| `Makefile` | build/test targets; `make test` is the canonical test command |
| `install.sh` | one-liner bootstrap script for end users |
| `legacy/` | one-file tombstones for retired subprojects (what it was, how to rebuild); the code is at tag `legacy-snapshot-20261102` |

---

## do-not rules

| do not | do instead |
| :--- | :--- |
| add runtime dependencies to `fox.sh` | keep the CLI dependency-free (curl, grep, bash only) |
| re-add retired code under `legacy/` | restore it elsewhere from the tag (`git checkout legacy-snapshot-20261102 -- legacy/<name>`) or rebuild from the tombstone; `legacy/` holds `.md` files only |
| write tests that bypass the `fox.sh` public interface | test via `fox.sh <command>` invocations only |
| run `make test` on the host | always test inside the sandbox (`make test` uses docker) |
| commit to `main` or `master` | branch using `YYYYMMDD-adjective-noun` format |
| commit secrets or credentials | stop immediately if any token/key is detected in staged files |
| add co-authored-by trailers | omit them entirely |

---

## how to work on this project

```bash
make build    # check dependencies
make image    # build sandbox docker image (run once, or after Dockerfile changes)
make test     # lint and test inside sandbox — mandatory before any commit
make sandbox  # interactive container to experiment with fox safely
make deploy   # sync artefacts to dist/
```

workflow: write the bats test first (TDD), implement in `fox.sh`, run `make test`, then commit.

---

## picking up a task

roadmap items are in [SPEC.md#roadmap](SPEC.md#roadmap). each item carries:
- a component tag `[component]` identifying the file or layer the task touches
- a difficulty tag `[easy]`, `[medium]`, or `[hard]`

pick a task matching your capability, write the bats test first, implement, then `make test` before committing.
