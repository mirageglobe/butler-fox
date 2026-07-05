# swissknife (jsk) — specification & architecture

> an opinionated collection of scripts and tools to standardize common tasks like media conversion, system configuration, and CLI utilities.

---

## 1. overview

swissknife (`jsk`) is a personal toolkit of standalone bash and python scripts. each tool is self-contained, prefixed `jsk-`, and installed into `~/.swissknife/bin` so they are available on `$PATH` without any runtime dependency manager.

### design philosophy

**standalone scripts, not a framework.** each `jsk-*` file is independently executable — no shared state, no daemon, no orchestration layer. a tool can be copied to any machine and run without the rest of the collection.

**opinionated defaults.** scripts encode the author's preferred approach for common tasks (media conversion settings, swap sizes, filename conventions). options exist but the defaults are the point.

**safe to run.** scripts guard against incompatible environments (e.g. `jsk-swapfile.sh` refuses to run on non-Linux). writes to the filesystem are scoped and explicit.

**start in bash, graduate to python, then go.** bash is the default because most tools are orchestration: wiring binaries together through pipes, exit codes, and environment. that is bash's native data model, not a compromise. a tool graduates when it outgrows the shell:

- **bash to python** when real logic appears: parsing structured data (json, csv), byte/string manipulation, arithmetic, dates, nested state, or arrays/dicts that matter. the trigger is a smell, not taste: a script faking data structures with `awk`/`sed`/`jq` pipelines, or sprouting nested conditionals, has outgrown bash.
- **python to go** when the tool needs a single distributable binary (no runtime on the target), real performance, concurrency, or strong typing.

graduating has a cost: a bash tool loses the shared `jsk-bash-lib.sh` and `jsk-color.sh` helpers and adds a `uv`/venv dependency, so don't move a tool until it has earned it. the existing split reflects this; binary-wrapping checkers stay in bash, anything with parsing or logic is python.

| signal                              | language |
| :---                                | :---     |
| pipes, exit codes, env glue         | bash     |
| runs before deps are installed      | bash     |
| parsing structured data (json, csv) | python   |
| arithmetic, dates, regex on content | python   |
| arrays/dicts, nested state          | python   |
| >~100 lines of logic                | python   |
| single static binary, no runtime    | go       |
| performance or concurrency          | go       |

---

## 2. architecture

swissknife has no runtime architecture — it is a collection of scripts with a shared install convention.

```
repo/
├── jsk-*.sh          # bash tools (sourced or executed directly)
├── jsk-*.py          # python tools (executed via python3)
├── jsk-help          # bash tool discovery and listing
├── jsk-bash-lib.sh   # shared bash utility functions (sourced by other tools)
├── *.bats            # bats test files for bash tools
├── *-test.py         # pytest test files for python tools
├── Makefile          # lint, test, install targets
└── Vagrantfile       # ubuntu jammy VM for isolated testing
```

### install convention

`make ensure-swissknife` copies all `jsk-*` scripts into `~/.swissknife/bin` and appends the directory to `PATH` in `~/.bash_profile`. the operation is idempotent.

```
~/.swissknife/
├── bin/
│   ├── jsk-*.sh
│   ├── jsk-*.py
│   ├── jsk-help
│   ├── semver          # fetched from fsaintjacques/semver-tool
│   └── ...
└── completion/
    └── git-completion.bash
```

### shared library

`jsk-bash-lib.sh` is the only cross-tool dependency. tools that need shared functions source it directly. it is not a required dependency — tools that don't need it are fully independent.

### tool categories

| category      | tools                                                                      |
| :---          | :---                                                                       |
| core          | jsk-help, jsk-doctor.sh, jsk-install.sh, jsk-bash-lib.sh, jsk-ensure.sh  |
| system        | jsk-system-check.py, jsk-swapfile.sh, jsk-utf8-convert.sh, jsk-color.sh  |
| media         | jsk-mp3.sh, jsk-mp4.sh, jsk-png.sh, jsk-pdf.sh                           |
| data          | jsk-kvdb.sh, jsk-sqldb.sh, jsk-decode-vbe.py                              |
| devops        | jsk-configuration-manager.sh, jsk-git-cache-meta.sh, jsk-watch.sh        |
| network       | jsk-check-sftp.sh, jsk-check-socket.sh, jsk-port.sh                       |
| files         | jsk-filename-fixer.sh, jsk-env.sh, jsk-jwt.sh                             |

---

## 3. technology stack

| component   | technology         | purpose                                      |
| :---        | :---               | :---                                         |
| bash tools  | bash (shellcheck)  | primary scripting language for most tools    |
| python tools| python 3 (uv)      | system diagnostics, vbe decoder              |
| testing     | bats               | unit tests for bash tools                    |
| testing     | pytest / unittest  | unit tests for python tools                  |
| linting     | shellcheck         | static analysis for all bash scripts         |
| install     | GNU make           | lint, test, and install automation           |
| vm testing  | vagrant + ubuntu   | isolated linux testing environment           |
| ci          | github actions     | shellcheck on push/pr                        |

---

## 4. file structure

```
swissknife/
├── jsk-bash-lib.sh              # shared bash utility functions
├── jsk-bash-lib-test.bats       # bats tests for bash-lib
├── jsk-check-sftp.sh            # SFTP connectivity validator
├── jsk-check-socket.sh          # Unix socket health check
├── jsk-color.sh                 # ANSI color chart display
├── jsk-color-test.bats          # bats tests for color tool
├── jsk-configuration-manager.sh # dotfile/env config manager
├── jsk-decode-vbe.py            # VBScript encoded file decoder
├── jsk-doctor.sh                # dependency status checker
├── jsk-ensure.sh                # local dependency checker
├── jsk-env.sh                   # .env vs .env.example diff
├── jsk-filename-fixer.sh        # filename normalizer
├── jsk-git-cache-meta.sh        # git file metadata cache
├── jsk-help                     # tool discovery and listing
├── jsk-install.sh               # bootstrap installer (legacy)
├── jsk-jwt.sh                   # JWT token decoder
├── jsk-kvdb.sh                  # JSON key-value store
├── jsk-mp3.sh                   # MP3 media conversion
├── jsk-mp4.sh                   # MP4 media conversion
├── jsk-pdf.sh                   # PDF manipulation
├── jsk-png.sh                   # PNG image optimization
├── jsk-port.sh                  # port-to-process lookup
├── jsk-sqldb.sh                 # MySQL/MariaDB backup utility
├── jsk-swapfile.sh              # Linux swapfile manager
├── jsk-system-check.py          # cross-platform system diagnostic
├── jsk-system-check-test.py     # tests for system-check
├── jsk-utf8-convert.sh          # UTF-8 conversion utility
├── jsk-watch.sh                 # command interval runner
├── Makefile
├── Vagrantfile
├── README.md
└── SPEC.md
```

---

## 5. build & run

```bash
# install all tools to ~/.swissknife/bin
make ensure-swissknife

# lint all bash scripts
make lint

# run all tests (bats + python)
make test

# run both lint and test
make all

# run a tool directly
bash ./jsk-swapfile.sh
./jsk-system-check.py
```

### prerequisites

- bash 4+
- python 3 (with `uv` recommended for python tools)
- shellcheck (for `make lint`)
- bats (for bash tests)
- vagrant + virtualbox (optional, for VM testing)

---

## 6. roadmap

### near term

- [x] `[core]` add SPEC.md  [easy]
- [ ] `[core]` add version field to each tool and surface it in `jsk-help`  [easy]
- [ ] `[core]` unify header comment format across all tools (author, source, license, purpose, version)  [easy]
- [ ] `[install]` make `ensure-swissknife` idempotent for `.zshrc` / `.zprofile` in addition to `.bash_profile`  [easy]
- [ ] `[core]` add `jsk-update` tool to pull latest scripts from remote and reinstall  [medium]
- [ ] `[test]` expand bats coverage to all bash tools with a `--help` or no-arg smoke test  [medium]
- [ ] `[test]` add bats smoke tests for jsk-doctor, jsk-jwt, jsk-port, jsk-env  [easy]
- [ ] `[system]` add macOS support to `jsk-swapfile.sh` or document clearly why it is linux-only  [easy]

### ideas

- [x] `[core]` `jsk-doctor` — checks that all tool dependencies (ffmpeg, imagemagick, mysql, etc.) are installed and prints a status table  [medium]
- [ ] `[media]` `jsk-mp3.sh` / `jsk-mp4.sh` batch mode — convert all matching files in a directory  [easy]
- [ ] `[data]` `jsk-kvdb.sh` — add expiry / TTL support for keys  [hard]
- [ ] `[install]` one-liner remote install script (curl pipe bash, no repo clone required)  [medium]
- [ ] `[core]` tab-completion for `jsk-*` tool names in bash/zsh  [medium]

---

## 7. decisions

- **`jsk-` prefix for all tools**: prevents namespace collisions on `$PATH`; makes the collection easy to discover with tab completion or `jsk-help`.
- **no shared runtime**: each script is independently executable; no import/require chain means no install failures due to missing dependencies at load time.
- **`~/.swissknife/bin` install target**: user-local install avoids `sudo`; keeps system `/usr/local/bin` clean.
- **bash over POSIX sh**: bash is ubiquitous and allows arrays, `[[ ]]`, and `source`; strict POSIX portability is not a goal.
- **bats for bash testing**: closest analogue to unit testing in shell; integrates naturally with `make test`.
- **vagrant for linux testing**: macOS is the dev host but several tools (e.g. `jsk-swapfile.sh`) target Linux only; vagrant provides a reproducible test environment without CI overhead.
- **start in bash, graduate to python/go**: bash is the default for orchestration tools (pipes, exit codes, env glue); a tool moves to python when it grows real logic (parsing, data structures, byte work) and to go when it needs a single static binary, performance, or concurrency. graduating costs the shared bash helpers and adds a runtime dependency, so it is deferred until the tool earns it.
- **`jsk-bash-lib.sh` as opt-in**: tools source it only if they need it — no mandatory coupling.

---

## 8. complexity score

| dimension   | score | notes                                                   |
| :---        | :---  | :---                                                    |
| overall     | 1 / 5 | collection of independent scripts; no runtime coupling  |
| core/install| 2 / 5 | idempotent installer with PATH and profile manipulation |
| media       | 2 / 5 | thin wrappers around ffmpeg/imagemagick                 |
| data        | 2 / 5 | file-backed key-value stores; no concurrency            |
| system      | 2 / 5 | cross-platform guards add conditional complexity        |
| testing     | 1 / 5 | bats + pytest; straightforward assertions               |
