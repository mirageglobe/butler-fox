# samurai (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/samurai`

## what it was

a numbered-menu runner for machine setup commands ("update this box", "install nginx", "show open ports"), in three generations. originally its own repo (github.com/mirageglobe/samurai), later folded into swissknife (the python header names github.com/mirageglobe/swissknife; butler-fox now has an active `sub-projects/swissknife`). the three files were added here 2026-07-04 (pr 22) to keep them as reference. 9 KB total, all of it either unfinished or aimed at ubuntu 14.04 era servers.

## the three files

- **`samurai-legacy.sh`** (5.8 KB, "samurai v2"): the only complete one. a bash script with a menu table of arrays `UI_CMD_<n>=( "description" "command" )`, numbered by group: 0 to 4 core (exit, update samurai by piping its `install.sh` from github master to bash, remove samurai, toggle showcmd, clear), 10 to 25 operating system (passwd, apt update and cleanup, dist-upgrade, build-essential, virtualbox guest additions, users list, restart shell, show ip via icanhazip.com, disk space, kernel, release, open ports via `netstat -lnptu`, smb shares, memory, unattended-upgrades), 30 to 32 package managers (linuxbrew, node via nvm 0.24.0, latest git ppa), 40 to 44 security (clamav and daemon, chkrootkit, rkhunter, ufw with ssh and 80, fail2ban with sendmail), 50 to 52 databases (sqlite, mongodb 3.0 and mariadb 10.0 for ubuntu trusty), 60 to 61 servers (nginx stable ppa, php5-fpm), 70 imaging (avconv, pngquant, graphicsmagick). usage: `samurai help`, `samurai ui` (lists every numbered entry), `samurai ui <n>` (runs entry n through `eval`). the documented `<yaml file> <command number>` mode is a stub: `runScript` only echoes "hello". in the code the variable names are swapped (`SK_CMD_CMD` holds the description, `SK_CMD_DESC` holds the command) but it runs the right element.
- **`samurai.py`** (2.9 KB): a python 3 port of the menu loop for macOS only (exits with a message on any other platform). prints a banner and the menu, reads a number, 0 quits, 3 toggles show-command mode, any other number runs `samuraimap[n]['cmd']` through `os.system`, then waits for enter and clears the screen. **`samuraimap = {}` is empty**, so no command is registered: the loop works, the menu has nothing in it. it also sketches "ninja mode", in which commands are not executed but written into a `scroll.sh` of bash commands that can be fed to vagrant.
- **`samurai.yml`** (394 bytes): the data format meant to replace the hard-coded table. a top-level `scroll` with `name`, `desc` and a `tasklist` of `task` entries, each with `name`, `desc`, `pid` and a `cmd` list of shell lines. the sample has two tasks under the same key `task`, which a yaml parser collapses to the last one; it should be a list.

## what depends on it

nothing in this repo. the active `sub-projects/swissknife/` installers (`jsk-install.sh`, `jsk-configuration-manager.sh`) fetch samurai from raw urls in github.com/mirageglobe/samurai, not from this folder, and `swissknife/README.md` has a todo "refactor samurai script".

## to rebuild it

the idea worth keeping is data-driven scrolls: a yaml file of named tasks with command lists, a runner that either executes them or (ninja mode) emits a script instead. build that around a list-of-tasks yaml, a small python or bash runner, and a dry-run switch. do not reuse the command table as is: php5, mongodb 3.0, mariadb 10.0, the linuxbrew ruby installer, nvm 0.24.0 and the ubuntu ppa steps are all obsolete. the useful ops one-liners (show ip, disk space, open ports, memory) are one line each and easy to retype.
