# butler fox

![GitHub](https://img.shields.io/github/license/mirageglobe/butler-fox.svg)

- maintainer : jimmy mg lim (mirageglobe@gmail.com)
- source : https://github.com/mirageglobe/butler-fox

```
                             .::::::.
        ..:=====:..        .::::::::::.
    ..:=============:..   .::::::::::::.    Butler
   :==================: .::::::::::::.      Fox
   :==================:::::::::::::::
 .::.=================::::::::::::::
 :::..==============..:::.    ::::
  :.:::::::::::::::::::      :::::
    :: .:::::.      ::        ::::.
     ::             :
```

fox is a local machine management CLI that fights forgetfulness. instead of remembering exact flags, package names, and command sequences, you ask fox. it wraps the commands a developer uses daily behind a named, searchable interface.

evolved from samurai (2013) → fox (2016) → butler-fox (current).

## features

- named commands: `fox system`, `fox ssh`, `fox network`
- keyword search across all tools: `fox s <term>`
- per-tool reference notes with local override support
- local notes: extend any tool with your own tips at `~/.fox/notes/<tool>.sh`
- zero dependencies — bash, curl, grep
- works on macOS and debian/ubuntu

see [SPEC.md](SPEC.md) for the project roadmap.

## install

requirements: bash 4.0+, curl

```bash
curl -fsSL https://raw.githubusercontent.com/mirageglobe/butler-fox/main/install.sh | bash
```

restart your shell, then:

```bash
fox help              # usage summary
fox system            # show system info, disk, memory, processes
fox system notes      # reference URLs and tips for system commands
fox s <term>          # search all tools by keyword
fox update            # update fox to latest version
```

## commands

| command              | behaviour                                          |
| :------------------- | :------------------------------------------------- |
| `fox <tool>`         | show subcommands for a tool                        |
| `fox <tool> notes`   | show reference URLs and usage notes for a tool     |
| `fox <tool> <cmd>`   | run a specific action                              |
| `fox s <term>`       | search all tools by keyword                        |
| `fox update`         | pull latest fox from release                       |
| `fox uninstall`      | remove `~/.fox` from this machine                  |
| `fox help`           | usage summary                                      |

## local notes

extend any tool with personal notes without modifying fox itself:

```bash
# create a notes file for a tool, e.g. ssh
mkdir -p ~/.fox/notes
cat > ~/.fox/notes/ssh.sh << 'EOF'
cat << 'EOM'
  work jumpbox: ssh -J bastion.company.com user@internal-host
EOM
EOF

fox ssh notes   # shows distributed notes + your local notes appended
```

## uninstall

```bash
rm -fr ~/.fox
```

## contribute

- bugs and suggestions: https://github.com/mirageglobe/butler-fox/issues
- pull requests welcome — see SPEC.md for architecture and build instructions

before submitting a PR:

```bash
make test         # lint (shellcheck) + bats test suite — must pass
make all          # build → test → deploy
```

---

[buy me a coffee](https://buymeacoffee.com/mirageglobe)
