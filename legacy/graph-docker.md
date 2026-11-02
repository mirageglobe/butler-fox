# graph-docker (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/graph-docker`

## what it was

a debian docker image whose entrypoint is `graph-easy`, to turn graphviz-style `.dot` text into ascii diagrams without installing perl packages on the host. three files, 2 KB, added 2026-05-10. the standalone, maintained version of the same idea is the `libgraph-easy-docker` repo (github.com/mirageglobe/libgraph-easy-docker); this is the earlier in-repo copy.

## how it was used

```bash
docker build -t butlerfox-graph .
docker run -it -v $(pwd):/app butlerfox-graph dotgraph.dot
```

the sample input `dotgraph.dot` is exactly:

```
digraph graphname {
    a -> b -> c;
    b -> d;
}
```

## the image

- base `debian:bullseye-slim` (the file lists debian 9 to 12 codenames in a comment).
- build args `BUILD_DATE` and `VCS_REF`, and `org.label-schema.*` labels: name `butlerfox-graph-debian-11`, vcs-url and url `github.com/mirageglobe/butlerfox`.
- env: `TERM=xterm`, `DEBIAN_FRONTEND=noninteractive`, `APPS` = bash, fd-find, libgraph-easy-perl, python3, ripgrep, tree, vim; `DEPS` = apt-utils, build-essential, curl, make, tini, wget.
- steps: `apt upgrade -y`, then `apt update && apt install --no-install-recommends $DEPS`, then the same for `$APPS`; `WORKDIR /app`.
- `ENTRYPOINT ["tini", "--", "graph-easy"]`, `CMD ["--help"]`; a commented alternative entrypoint is `["/bin/sh", "-c"]`.

## quirks

- `apt upgrade -y` runs before any `apt update`, so it upgrades against stale package lists; the order should be update, then upgrade.
- a leftover header comment says the image is "for changemedescribe" (copy-pasted from a template).
- `hound-docker` has the same shape and its README is a verbatim copy of this one.

## to rebuild it

about 15 lines: a slim debian or alpine base, `libgraph-easy-perl` and `tini`, `WORKDIR /app`, entrypoint `tini -- graph-easy`. the sample `.dot` file above is the only test input. dev tools in the image (fd, ripgrep, tree, vim, python3, build-essential) are not needed to run graph-easy and can be dropped.
