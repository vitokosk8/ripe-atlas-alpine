# ripe-atlas-alpine

[![GitHub last commit](https://img.shields.io/github/last-commit/vitokosk8/ripe-atlas-alpine)](https://github.com/vitokosk8/ripe-atlas-alpine/commits/master/)
[![GitHub License](https://img.shields.io/github/license/vitokosk8/ripe-atlas-alpine)](https://github.com/vitokosk8/ripe-atlas-alpine/blob/master/LICENSE)

Docker images of RIPE Atlas Software Probe using Alpine Linux.

This is a fork of [CTassisF/ripe-atlas-alpine](https://github.com/CTassisF/ripe-atlas-alpine), adapted to publish images under this account's GitHub Container Registry namespace and to build a pinned upstream revision.

Based on the [official code provided by RIPE NCC](https://github.com/RIPE-NCC/ripe-atlas-software-probe), with a few tweaks to make it run under Alpine Linux.

## Images

Images are published to GitHub Container Registry:

```
ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Images are built for the following architectures:

* 386
* amd64
* arm/v6
* arm/v7
* arm64/v8
* ppc64le
* riscv64
* s390x

## Upstream version

The build clones the upstream RIPE NCC probe and checks out a fixed commit, defined in two places that must stay in sync:

* `PROBE_REF` in the `Dockerfile` (`ARG`, default value).
* `PROBE_REF` in `.github/workflows/docker-build.yml` (workflow `env`).

To build another upstream release, change both values, or override the `Dockerfile` argument at build time:

```bash
docker build --build-arg PROBE_REF=<tag-or-commit> -t ripe-atlas-alpine .
```

## Docker

Pull the latest image:

```bash
docker pull ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Then run the probe:

```bash
docker run --detach \
  --name ripe-atlas \
  --restart unless-stopped \
  --volume ~/ripe-atlas/probe--etc--ripe-atlas:/probe/etc/ripe-atlas \
  --volume ~/ripe-atlas/probe--var--run--ripe-atlas--status:/probe/var/run/ripe-atlas/status \
  --mount type=tmpfs,destination=/probe/var/spool/ripe-atlas/data \
  ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Check if the container is running using `docker ps`, or check its logs using:

```bash
docker logs ripe-atlas
```

The first run will create the directory containing the probe configuration and SSH key.

Use the public SSH key `probe_key.pub` to register your probe here:

https://atlas.ripe.net/apply/swprobe/

## Docker Compose

The following is a minimal `docker-compose.yml` example:

```yaml
services:
  ripe-atlas:
    image: ghcr.io/vitokosk8/ripe-atlas-alpine:latest
    container_name: ripe-atlas
    restart: unless-stopped
    volumes:
      - ~/ripe-atlas/probe--etc--ripe-atlas:/probe/etc/ripe-atlas
      - ~/ripe-atlas/probe--var--run--ripe-atlas--status:/probe/var/run/ripe-atlas/status
      - type: tmpfs
        target: /probe/var/spool/ripe-atlas/data
```

Start the probe with:

```bash
docker compose up --detach --pull always
```

Check its status and logs with:

```bash
docker compose ps
docker compose logs
```

The configuration and probe status directories are kept outside the container, while the probe's measurement data is stored in a temporary filesystem and is lost when the container is recreated.

## Publishing from a fork

The workflow pushes to GitHub Container Registry using the built-in `GITHUB_TOKEN`, so no extra secrets are required. Scheduled runs are disabled by default in forks; enable the workflow in the Actions tab if you want the daily upstream check.
