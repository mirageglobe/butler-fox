# hound-docker (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/hound-docker`

## what it was

a placeholder alpine image for a planned "hound" part of butler fox. two files, 1 KB, added 2026-05-10. nothing was ever built on it: the line that would have copied the tool in is commented out (`# COPY src/hound /app`), the default command just prints the environment (`CMD ["env"]`), and the README is a verbatim copy of `graph-docker`'s, describing the graph image's build and run, not this one. what "hound" was meant to do is not written anywhere in the repo; the toolset (fd, ripgrep, tree, python3) suggests a file or code search sandbox, which is an inference.

## the image

- base `alpine:latest`; build args `BUILD_DATE` and `VCS_REF`; `org.label-schema.*` labels with name `butlerfox-hound-alpine`, vcs-url and url `github.com/mirageglobe/butlerfox`.
- env: `TERM=xterm`; `APPS` = bash, fd, python3, ripgrep, tree, vim; `DEPS` = alpine-sdk, curl, make, tini, python3, wget.
- steps: `apk add --no-cache --update $DEPS`, then `apk add --update $APPS`; `WORKDIR /app`.
- `ENTRYPOINT ["tini", "--"]`, `CMD ["env"]`.

## to rebuild it

nothing to preserve beyond the recipe above, which is a generic alpine dev sandbox. if a "hound" tool is ever designed, start from its requirements, not from this image. see [graph-docker.md](graph-docker.md) for the sibling image this was cloned from.
