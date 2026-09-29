# changelog

all notable changes to this project are documented here.

format: [keep a changelog](https://keepachangelog.com/en/1.0.0/)
versioning: [semantic versioning](https://semver.org/spec/v2.0.0.html)

---

## [Unreleased]

### added

- `sub-projects/swissknife/`: swissknife migrated in as a standalone sub-project (own Makefile, bats/pytest tests, SPEC.md), matching the `legacy/` precedent but for an active project; runs unchanged via `cd sub-projects/swissknife && make test`
- `make test-swissknife`: root target delegating to the swissknife sub-project's own test suite
- SPEC.md roadmap ideas for 9 swissknife tools that are clean fits to graduate into native fox commands (`fox doctor`, `fox jwt`, `fox env`, `fox color`, `fox convert`, `fox rename`, `fox watch`, plus new subcommands on `fox_git` and `fox_network`); tools that overlap with `fox_system` or conflict with fox's own stated non-goals (remote orchestration, config management) are flagged as staying in swissknife

### fixed

- stray `nsk-` prefixed asset filename renamed to match the `jsk-` convention

---

## [1.0.0] - 2026-05-10

### added

- `fox git` — branch (datestamp + random adjective-animal name), prune, show, size, notes
- `fox docker` — show, ps, rm, imgprune, notes
- `fox tar` — notes reference for tar, zip, xz
- `fox rsync` — notes reference for rsync and scp
- `fox tmux` — notes reference for sessions, windows, panes
- `fox date` — now, stamp, time, notes
- `fox system restart` — restart current shell via `exec $SHELL -l`
- `fox_require` helper — exits with clear error when a dependency is not on PATH
- `fox_notes_header` helper — dim styled section headers for notes output
- local notes now accept `.md` and `.txt` (dropped `.sh` for safety)
- help menu grouped into `tools` and `fox` sections
- `notes` subcommand visually separated with blank line in per-tool help
- git added to sandbox Dockerfile for git subcommand tests (45 tests total)

### changed

- notes layout: section headers (`reference`, `notes`, `local notes`) now styled with dim color
- notes sections use heredocs with a helper rather than printf chains
- local notes file lookup order: `.md` → `.txt` (cat only; no shell execution)

---

## [0.1.0] - 2026-05-10 (legacy — numbered-menu era, pre-rewrite)

### added

- `fox system` — info, disk, memory, processes, users, version, weather, notes
- `fox network` — ip4, ip6, ports, notes
- `fox ssh` — keygen, copy-id, notes
- `fox update` — pulls latest release from GitHub into `~/.fox/bin/fox`
- `fox uninstall` — removes `~/.fox` from the machine
- `fox_print_local_notes` — per-tool local notes from `~/.fox/notes/<tool>.sh`
- docker sandbox — `make image`, `make test`, `make sandbox` for safe testing
- shellcheck + bats-core test suite (21 tests)
- MIT license, CONTRIBUTING.md with CLA clause
- SPEC.md, AGENTS.md, CLAUDE.md

### changed

- replaced numbered menu (`fox m`) with named-command UX (`fox <tool>`)
- moved legacy subprojects (clamshield, fox-go, samurai, graph-docker, hound-docker) to `legacy/`
- replaced Apache 2.0 license with MIT

### removed

- numbered menu commands (`fox m`, `fox mm`, `fox m <n>`)
- CI workflows (codeql, superlinter) — replaced by docker-based `make test`
