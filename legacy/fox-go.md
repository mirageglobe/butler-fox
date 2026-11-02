# fox-go (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/fox-go`

## what it was

an experiment to rewrite butler fox (the bash lookup cli) in go with cobra. its whole README is one line: "this is an experiment to build butler fox with go". it is a pure `cobra init` scaffold from 2021 with no commands of its own, so nothing here is worth preserving as code. added to this repo 2026-05-10. the bash `fox` cli won: the same day's commit 59f9bf8 rewrote fox with named commands, a docker sandbox and a cleaner layout.

## what is in it

- `go.mod`: module `github.com/mirageglobe/butlerfox`, go 1.17, `github.com/spf13/cobra` v1.2.1, `github.com/spf13/viper` v1.8.1 (plus their indirect dependencies). `go.sum` (60 KB) is regenerable with `go mod tidy`.
- `main.go`: imports `github.com/mirageglobe/butlerfox/cmd` and calls `cmd.Execute()`.
- `cmd/root.go`: the untouched cobra generator output. a root command `butlerfox` with placeholder `Short` and `Long` text, no `Run`, no subcommands. a persistent `--config` flag (default `$HOME/.butlerfox.yaml`) and a placeholder local flag `-t/--toggle`. `initConfig()` points viper at the home directory with config name `.butlerfox` (type yaml), turns on `AutomaticEnv()`, and prints "Using config file: ..." to stderr when one is found.
- `LICENSE`: Apache 2.0, the files carry a `Copyright 2021 Jimmy Lim MG` header.

## to rebuild it

regenerate the scaffold: `cobra-cli init --pkg-name github.com/mirageglobe/butlerfox` (cobra-cli is the successor to the `cobra` generator used here), then add a subcommand per fox topic. before doing that, check why the bash version won: a go port gives one static binary and real tests, at the cost of the quick edit-and-run loop of a shell library. the go-versus-bash decision is not recorded anywhere beyond the 2026-05-10 commit.
