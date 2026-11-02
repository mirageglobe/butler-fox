# clamshield-cli (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/clamshield-cli`

## what it was

six bash scripts wrapping clamav (`clamscan`, `freshclam`) for scheduled virus scanning of small servers and laptops. added to this repo 2026-05-10 (commit 59f9bf8, the fox rewrite); the script headers say the source was github.com/mirageglobe/jsk. total 10 KB. unfinished: several scripts have bugs (below), so treat it as notes on a design, not a working tool.

## files and what each does

| script                        | role                                                                                               |
| :---------------------------- | :------------------------------------------------------------------------------------------------- |
| `clamshield`                  | dispatcher, one argument: `scan` runs `clamscan .`, `update` runs `freshclam`, `help` prints usage |
| `clamshield-bootstrap`        | debian-only installer: aborts on mac, cygwin, msys, win32, freebsd or unknown `$OSTYPE`            |
| `clamshield-update`           | stop the `clamav-freshclam` service, `rm /var/lib/clamav/*`, run `freshclam`, start the service    |
| `clamshield-scan-full`        | chunked full sweep (the interesting one, see below)                                                |
| `clamshield-scan-progressive` | scan files changed in the last day, remove infections, mail the result                             |
| `clamshield-scan-quick`       | byte-identical copy of `-progressive` (same md5), never differentiated                             |

## the design worth keeping

- **chunked full scan for low-memory devices.** a whole-system `clamscan` made small machines seize up. instead: `find $CAV_SCANDIR -type f` writes every path to a monthly sweep list (`clamshield.sweeplist-YYYYMM.txt`, stderr filtered for "Permission denied"); each run takes the first N lines (`CAV_SCANNUMFILE=10`), scans only those, then deletes them from the sweep list, so repeated runs resume and finish the whole tree over time. the delete uses `sed -i'.tmp' -e "1,${N}d"`, the form that works on both GNU and macOS sed.
- **scan flags:** `--max-filesize=10M --max-scansize=10M`, `--infected --suppress-ok-results`, `--log=/var/log/clamav/scan.log`.
- **excluded directories** (regex form): `^/sys/ ^/dev/ ^/proc/ ^/mnt/ ^/media/`. default scan root for the full sweep was `/usr`; for the progressive scan `/var/www/`.
- **definition refresh flow:** stop the freshclam service (it holds a lock), delete `/var/lib/clamav/*` because definitions corrupt now and then (the comment suggests monthly), run `freshclam`, start the service.
- **removal is opt-in:** `--remove` appears only in the progressive script; the full scan leaves a commented hint to add it or isolate files instead.
- **notify:** if the temp result file contains `FOUND`, mail it to `CAV_EMAIL` (placeholder `youradminemail@yourdomain.com`); the full scan has the mail line commented out.

## bugs as written (do not copy blindly)

- `clamshield-scan-full` never writes the chunk it takes to `clamshield.scanfilelist.tmp`, so `--file-list` points at a file nothing creates. it needs the first N lines saved to that file before they are deleted from the sweep list.
- the `FOUND` check is `grep FOUND "$f" | grep -c` with no pattern for the second grep, so the count never works as intended; use `grep -c FOUND "$f"`.
- `clamshield-bootstrap` mixes layouts: `apt-get install clamav` on debian but then copies configs under the homebrew path `/usr/local/etc/clamav`; it calls `push` and `pop` (typos for `pushd` and `popd`) and copies `clamav.conf.sample` where `clamd.conf.sample` is meant.
- `clamshield` hardcodes `app_os="MAC"`, calls an undefined `die`, and requires exactly one argument.

## to rebuild it

four pieces, each a few lines: an os-aware bootstrap (apt on debian, brew on mac, config under the right prefix); an update step (the stop, refresh, start flow); a recent-files scan (`find -mtime -1` into `--file-list`); and the chunked sweep with the save-the-chunk fix. dependencies: clamav (`clamscan`, `freshclam`), the `clamav-freshclam` service (systemd or sysv), a working `mail`, POSIX `find` and `sed`. SPEC.md, "clamav notes", points here for the scan patterns.
