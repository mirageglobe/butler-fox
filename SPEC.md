# butler-fox — technical specification

> local machine management CLI that fights forgetfulness — a curated, distributable reference and command runner for the tools a developer uses daily.

---

## purpose and direction

the core problem butler-fox solves is **forgetfulness**: you know a task needs doing but can't recall the exact flags, the right package name, or the correct order of commands. fox is the answer to "what was that command again?" for solo developers managing their own machines.

the target environment is **local machines** (macOS and debian/ubuntu). this keeps the tool personal and opinionated — it assumes a logged-in user, a home directory, and standard dev tooling.

### history

butler-fox began as **samurai** — a Python-based system helper script (`samurai.py`) for macOS and linux. the python dependency proved too heavy for minimal server environments, so it was rewritten in bash and renamed **fox** to reflect the lighter, faster character of the tool. the legacy samurai scripts are preserved in `src/samurai/` as read-only historical reference.

the current bash implementation (`fox.sh`) is the third iteration of that idea. the Go reimplementation (`fox-go/`) is underway as a fourth, targeting binary distribution without a bash dependency.

### sub-projects

`sub-projects/` holds active, independently maintained tool collections that live in this repo but keep their own build, tests, and standalone-run property; this is distinct from `legacy/`, which holds retired/abandoned code kept only as historical reference.

- `sub-projects/swissknife/`: migrated from the standalone `swissknife` github repo (now archived as `zip-swissknife`); a bag of independent `jsk-*` scripts (media conversion, system checks, small dev utilities) with its own Makefile, bats/pytest tests, and SPEC.md. run standalone via `cd sub-projects/swissknife && make test`, or via the root `make test-swissknife`. see the roadmap's `ideas` section for which tools are candidates to graduate into native `fox` commands.

### design inspiration

the user's personal `dot.fox.bashrc` — an 8,500-line, 139-function bash reference library sourced into the shell daily — defines what this tool should aspire to be. that file is a personal scratchpad: powerful but unshareable, untested, and hard to maintain.

butler-fox is the **curated, distributable, tested version** of that pattern. same UX philosophy (named commands, per-tool notes, keyword search), but installable by anyone via `curl | bash` and verifiable via `make test`.

### what fox is

- a named-command reference and runner: `fox ssh`, `fox docker`, `fox git`
- per-tool depth: each tool has subcommands, reference notes, and curated command strings
- searchable across all tools: `fox s <term>`
- zero-dependency bootstrap: installs with one `curl | bash`, works on a fresh machine
- opinionated and curated: reflects current best practice, not every possible option

### what fox is not

- a configuration management tool (that's ansible)
- a package manager (that's brew/apt)
- a remote orchestration tool
- a replacement for the tools it wraps

---

## overview

butler-fox exposes a single binary (`fox`) with two complementary UX modes:

**named-command mode (primary)** — `fox <tool> [subcommand]`
the main interface. each supported tool has its own subcommand with actions and reference notes. memorable, discovereable, no number required.

**numbered menu mode (secondary)** — `fox m [n]`
retained for browsing the full command list when you don't know the tool name. `fox m` lists all; `fox m <n>` runs one directly.

both modes share the same underlying command store and are searchable via `fox s <term>`.

---

## command interface

### top-level commands

| command              | behaviour                                                  |
| :--- | :--- |
| `fox <tool>`         | show help and subcommands for a tool                       |
| `fox <tool> notes`   | show reference URLs and usage notes for a tool             |
| `fox <tool> <cmd>`   | execute a specific action for a tool                       |
| `fox s <term>`       | search all tool descriptions and notes for keyword         |
| `fox m`              | browse full numbered menu                                  |
| `fox mm`             | verbose numbered menu (includes command strings)           |
| `fox m <n>`          | execute numbered menu item directly                        |
| `fox update`         | pull latest `fox-latest.sh` from release URL into `~/.fox/bin/fox` |
| `fox uninstall`      | remove `~/.fox` from this machine                          |
| `fox help`           | usage summary                                              |

### tool subcommand pattern

each tool follows a consistent case-switch structure:

```bash
fox_ssh () {
  case "$1" in
  "keygen")
    # generate an ed25519 key pair
    ssh-keygen -t ed25519 -C "$(whoami)"
    ;;
  "copy-id")
    # copy public key to remote host
    ssh-copy-id "$2"
    ;;
  "notes")
    cat << 'EOM'
    :: reference ::
      https://www.ssh.com/academy/ssh/keygen

    :: notes ::
      prefer ed25519 over rsa for new keys
      authorized_keys lives at ~/.ssh/authorized_keys on the remote
    EOM
    ;;
  *)
    printf "fox ssh subcommands:\n"
    printf "  keygen       generate ed25519 key pair\n"
    printf "  copy-id      copy public key to remote host\n"
    printf "  notes        reference URLs and usage notes\n"
    ;;
  esac
}
```

### tagging system

function headers carry searchable tags:

| tag      | meaning                                         |
| :--- | :--- |
| `[help]` | function includes reference notes (`notes` subcommand) |
| `[tool]` | function has multiple executable subcommands    |

`fox s ssh` greps across all function header comments for the term.

### curated tool coverage

ordered by implementation priority:

| tool           | subcommands                                              | platform    | status      |
| :---           | :---                                                     | :---        | :---        |
| `fox system`   | info, disk, memory, processes, users, version, weather, notes | mac + linux | active |
| `fox network`  | ip4, ip6, ports, notes                                   | mac + linux | planned     |
| `fox ssh`      | keygen, copy-id, notes                                   | mac + linux | planned     |
| `fox pkg`      | update, upgrade, list, notes                             | mac + linux | planned     |
| `fox security` | ufw, clamav, fail2ban, chkrootkit, rkhunter, notes       | linux       | planned     |
| `fox git`      | status, log, branch, stash, cleanup, notes               | mac + linux | ideas       |
| `fox docker`   | ps, images, cleanup, exec, logs, notes                   | mac + linux | ideas       |
| `fox python`   | venv, uv, pip, notes                                     | mac + linux | ideas       |
| `fox node`     | nvm, install, notes                                      | mac + linux | ideas       |

---

## architecture

```
butler-fox/
├── src/
│   └── fox-sh/
│       ├── fox.sh             # canonical bash CLI (source of truth)
│       └── .fox.bash          # shell profile fragment — exports fox to PATH
├── test/
│   └── fox.sh.test            # bats test suite
├── dist/
│   ├── fox-latest.sh          # built artefact (copied from fox.sh by make deploy)
│   └── .fox.bash              # built artefact (copied from src by make deploy)
├── legacy/                    # archived subprojects — do not modify
│   ├── clamshield/            # electron GUI for ClamAV
│   ├── clamshield-cli/        # standalone bash scripts for ClamAV ops
│   ├── fox-go/                # Go reimplementation scaffold (deferred)
│   ├── graph-docker/          # debian graph container
│   ├── hound-docker/          # alpine ClamAV container
│   └── samurai/               # original python/bash predecessor
├── Dockerfile                 # sandbox image: curl, bats, shellcheck
├── install.sh                 # one-liner bootstrap for end users
└── Makefile
```

---

## technology stack

| component | language / runtime | key dependencies            |
| :--- | :--- | :--- |
| fox-sh    | bash 4.0+          | shellcheck, bats-core       |
| sandbox   | docker             | debian:stable-slim          |

---

## component breakdown

### fox-sh (`src/fox-sh/fox.sh`)

primary CLI. structure:

```
┌──────────────────────────────────────────────────────────────────┐
│  fox.sh                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │ print helpers│  │  OS detect   │  │     tool functions     │ │
│  │ print_fox    │  │  is_macos()  │  │  fox_system() [help]   │ │
│  │ print_success│  │  is_linux()  │  │  fox_network()[help]   │ │
│  │ print_error  │  └──────────────┘  │  fox_ssh()    [help]   │ │
│  └──────────────┘                    │  ...                   │ │
│                                      └────────────────────────┘ │
│  entry point dispatch:                                           │
│    fox <tool> [subcommand] → call fox_<tool> "$2"               │
│    fox update / uninstall  → built-in lifecycle commands        │
└──────────────────────────────────────────────────────────────────┘
```

**notes subcommand**

every tool function must implement `notes` as a heredoc with two sections, followed by local notes loaded from `~/.fox/notes/<tool>.sh` if it exists:

```
:: reference ::
  <url 1>
  <url 2>

:: notes ::
  <plain-english tips and gotchas>

:: local notes ::
  <appended from ~/.fox/notes/ssh.sh if present, otherwise "no local notes">
```

local notes are appended, never merged — the distributed notes are never modified by the user. the output always has a `:: local notes ::` section so the user knows the slot exists even when empty.

**local notes implementation**

each tool's `notes` subcommand calls a shared helper at the end of its heredoc output:

```bash
fox_print_local_notes () {
  local tool="$1"
  local notes_file="${HOME}/.fox/notes/${tool}.sh"
  printf "\n:: local notes ::\n"
  if [ -f "$notes_file" ]; then
    source "$notes_file"
  else
    printf "  no local notes. add them to ~/.fox/notes/%s.sh\n" "$tool"
  fi
}
```

the local notes file is plain bash — a heredoc, a printf, or any output-producing commands:

```bash
# ~/.fox/notes/ssh.sh
cat << 'EOM'
  work jumpbox: ssh -J bastion.company.com user@internal-host
  personal server: user@myserver.com (port 2222)
EOM
```

this keeps the extension format consistent with the rest of fox — no new syntax to learn.

**os gating**

`is_macos()` / `is_linux()` gate both tool functions (skip whole function if unsupported) and individual subcommands within a function. linux-only subcommands are hidden on macOS.

---

## install flow

```
curl -fsSL https://raw.githubusercontent.com/mirageglobe/butler-fox/main/install.sh | bash
  └─ copies fox.sh → ~/.fox/bin/fox
  └─ appends .fox.bash → ~/.bashrc or ~/.zshrc
  └─ fox now available on $PATH
```

flags: `-f` fail on server error, `-S` show error on failure, `-L` follow redirects.

uninstall: `rm -fr ~/.fox`

---

## test strategy

- **lint**: shellcheck on `fox.sh` — zero warnings before commit
- **unit**: bats-core (`test/fox.sh.test`) — every tool function must cover: default (no args), `notes`, at least one subcommand, and an unknown subcommand
- **sandbox**: all testing runs inside `debian:stable-slim` via docker — nothing touches the host machine

```
make image    # build sandbox image once (or after Dockerfile changes)
make test     # shellcheck + bats + install smoke test inside container
make sandbox  # interactive shell with fox hot-reloaded from src/
```

---

## decisions

| decision | chosen | why |
| :--- | :--- | :--- |
| named commands as primary UX | `fox ssh`, `fox docker` | memorable without a number; the user's daily `dot.fox.bashrc` proved this pattern works at scale |
| local notes as bash files | `~/.fox/notes/<tool>.sh` | keeps zero-dependency promise (no yaml parser needed); same format as the rest of fox; user already knows the pattern |
| local notes appended, never merged | `:: local notes ::` always shown | clear separation between distributed and personal knowledge; distributed notes stay unmodified and upgradeable |
| numbered menu removed | named commands only | two design languages in one tool was confusing; `fox system` etc. replace all numbered entries |
| per-tool `notes` subcommand | heredoc with reference URLs | reference material lives next to the commands it explains; no separate wiki to maintain |
| `[help]` / `[tool]` tags in comments | grep-searchable header comments | same pattern as `dot.fox.bashrc`; enables `fox s` without a manifest file |
| single-file bash | `fox.sh` is the canonical source | zero runtime dependencies; installs with a single curl on a fresh machine |
| local machine scope | macOS + debian/ubuntu only | keeps the command store curated and current; remote/server orchestration belongs in ansible |
| bash now, Go pivot deferred | bash is canonical; Go deprioritised | target is peer developers on macOS/linux — bash + Homebrew formula is sufficient; Go pivot is low-risk later because the command surface is already defined, content lifts straight to embedded strings, and the Homebrew formula change is one line; pivot when binary distribution to non-bash environments becomes a real need |
| bats-core for testing | bats | native bash test runner; integrates directly into `make test` |
| no system-wide install | `~/.fox/` user dir | avoids sudo; user-scoped binary reduces blast radius |

---

## complexity score

| dimension | score | notes                                              |
| :--- | :--- | :--- |
| overall   | 1 / 5 | single bash file; sandbox via docker               |
| fox-sh    | 2 / 5 | growing: tool functions add depth but stay in bash |

---

## roadmap

### phase 1 — foundation ✓

- [x] `[fox-sh]` fix `install.sh` shebang to `#!/usr/bin/env bash`  [easy]
- [x] `[fox-sh]` fix silent no-op when OS undetected — exit 1 with error  [easy]
- [x] `[fox-sh]` remove numbered menu — named commands only  [easy]
- [x] `[fox-sh]` implement `fox_print_local_notes` helper  [easy]
- [x] `[fox-sh]` implement `fox update` and `fox uninstall`  [easy]
- [x] `[fox-sh]` implement `fox system` — info, disk, memory, processes, notes  [easy]
- [x] `[fox-sh]` sandbox via docker — `make test`, `make sandbox`, `make image`  [easy]

---

### phase 2 — complete ✓

- [x] `[fox-sh]` add `users`, `version`, `weather`, `restart` to `fox_system`  [easy]
- [x] `[fox-sh]` implement `fox_network` — ip4, ip6, ports, notes  [easy]
- [x] `[fox-sh]` implement `fox_ssh` — keygen (ed25519), copy-id, notes  [easy]
- [x] `[fox-sh]` implement `fox_git` — branch, prune, show, size, notes  [easy]
- [x] `[fox-sh]` implement `fox_docker` — show, ps, rm, imgprune, notes  [easy]
- [x] `[fox-sh]` implement `fox_tar` — notes  [easy]
- [x] `[fox-sh]` implement `fox_rsync` — notes  [easy]
- [x] `[fox-sh]` implement `fox_tmux` — notes  [easy]
- [x] `[fox-sh]` implement `fox_date` — now, stamp, time, notes  [easy]
- [x] `[fox-sh]` add `fox_require` dependency check helper  [easy]
- [x] `[fox-sh]` local notes support `.md` and `.txt` (dropped `.sh` for safety)  [easy]

---

### phase 3 — near term

**`fox pkg`**

| subcommand | command                                              | platform    |
| :---       | :---                                                 | :---        |
| `update`   | `apt update && apt upgrade` / `brew update && brew upgrade` | mac + linux |
| `upgrade`  | `apt dist-upgrade`                                   | linux       |
| `list`     | `apt list --installed` / `brew list`                 | mac + linux |
| `notes`    | reference + local notes                              | mac + linux |

- [ ] `[fox-sh]` implement `fox_pkg` — update, upgrade, list, notes  [medium]

**`fox security`**

| subcommand    | command                              | platform |
| :---          | :---                                 | :---     |
| `ufw`         | install + allow ssh/80, enable       | linux    |
| `clamav`      | install clamav + clamav-daemon; freshclam; scan with exclude dirs | linux |
| `fail2ban`    | install sendmail + fail2ban          | linux    |
| `chkrootkit`  | install chkrootkit                   | linux    |
| `rkhunter`    | install rkhunter                     | linux    |
| `notes`       | reference + local notes              | linux    |

- [ ] `[fox-sh]` implement `fox_security` — ufw, clamav, fail2ban, chkrootkit, rkhunter, notes  [medium]
- note: `legacy/clamshield-cli/` contains reference scan patterns (exclude dirs, max-filesize, freshclam flow) to draw from for clamav notes content

**script safety scanning**

scan `fox.sh` for unsafe patterns beyond what shellcheck covers — guards against injection vectors and dangerous constructs that could be introduced as the tool grows.

| check | what to scan for |
| :--- | :--- |
| no `eval` | `eval` of any user-controlled or external input |
| no dynamic `source` | `source` / `.` of any file other than known local notes path (already removed `.sh` local notes) |
| no unvalidated external input | `$FOX_CMD`, `$FOX_OPT` passed to shell constructs without quoting |
| update URL integrity | `fox update` curls a script — verify it targets the canonical release URL only |

- [ ] `[fox-sh]` add scan step to `make test` — grep for `eval`, dynamic `source`, and bare curl-pipe patterns  [easy]
- [ ] `[fox-sh]` bats test: assert `fox update` URL matches expected release endpoint  [easy]

**distribution**

- [ ] `[fox-sh]` write Homebrew formula — copies `fox.sh` to `bin/fox`  [easy]

---

### ideas

**from `sub-projects/swissknife` migration** (see `sub-projects/swissknife/SPEC.md` for the source tools)

- `[fox-sh]` `fox doctor`: check dev tool deps (ffmpeg, imagemagick, mysql, etc.) are installed; from `jsk-doctor.sh`
- `[fox-sh]` `fox jwt`: decode JWT tokens; from `jsk-jwt.sh`
- `[fox-sh]` `fox env`: diff `.env` against `.env.example`; from `jsk-env.sh`
- `[fox-sh]` `fox color`: ANSI color chart reference; from `jsk-color.sh`
- `[fox-sh]` `fox convert <mp3|mp4|png|pdf>`: media conversion wrappers; from `jsk-mp3.sh`/`jsk-mp4.sh`/`jsk-png.sh`/`jsk-pdf.sh`
- `[fox-sh]` `fox rename`: normalize filenames to lowercase/hyphens; from `jsk-filename-fixer.sh`
- `[fox-sh]` `fox watch`: interval command runner; from `jsk-watch.sh`
- `[fox-sh]` extend existing `fox_git` with a `meta` subcommand: cache git file metadata; from `jsk-git-cache-meta.sh`
- `[fox-sh]` extend existing `fox_network` with a `port <n>` subcommand: port-to-process lookup; from `jsk-port.sh`
- note: `jsk-system-check.py` overlaps with existing `fox_system`, not worth porting; `jsk-swapfile.sh`, `jsk-configuration-manager.sh`, `jsk-check-sftp.sh` conflict with fox's own non-goals (remote orchestration, config management) and stay sub-project-only

- `[fox-sh]` `fox python` — uv, venv, pip notes
- `[fox-sh]` `fox node` — nvm, install, notes
- `[fox-sh]` `fox ssl` — inspect, verify, generate certificates
- `[fox-sh]` user-defined tools from `~/.fox/custom.sh` — personal functions without forking
- `[fox-sh]` `fox history` — last N commands run via fox, written to `~/.fox/history`
- `[fox-go]` Go reimplementation when binary distribution to non-bash environments is needed
