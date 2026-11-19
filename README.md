# ripe-atlas-alpine

Español | [English](README.en.md)

[![Último commit en GitHub](https://img.shields.io/github/last-commit/vitokosk8/ripe-atlas-alpine)](https://github.com/vitokosk8/ripe-atlas-alpine/commits/master/)
[![Licencia en GitHub](https://img.shields.io/github/license/vitokosk8/ripe-atlas-alpine)](https://github.com/vitokosk8/ripe-atlas-alpine/blob/master/LICENSE)

Imágenes Docker de la sonda de software RIPE Atlas sobre Alpine Linux.

Este es un fork de [CTassisF/ripe-atlas-alpine](https://github.com/CTassisF/ripe-atlas-alpine), adaptado para publicar las imágenes en el GitHub Container Registry de esta cuenta y para compilar una revisión fija del upstream.

Basado en el [código oficial proporcionado por RIPE NCC](https://github.com/RIPE-NCC/ripe-atlas-software-probe), con algunos ajustes para que funcione sobre Alpine Linux.

## Imágenes

Las imágenes se publican en GitHub Container Registry:

```
ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Las imágenes se construyen para las siguientes arquitecturas:

* 386
* amd64
* arm/v6
* arm/v7
* arm64/v8
* ppc64le
* riscv64
* s390x

## Versión del upstream

El build clona el probe upstream de RIPE NCC y hace checkout de un commit fijo, definido en dos sitios que deben mantenerse sincronizados:

* `PROBE_REF` en el `Dockerfile` (valor por defecto de `ARG`).
* `PROBE_REF` en `.github/workflows/docker-build.yml` (`env` del workflow).

Para construir otra versión del upstream, cambia ambos valores o sobrescribe el argumento al construir:

```bash
docker build --build-arg PROBE_REF=<tag-o-commit> -t ripe-atlas-alpine .
```

## Docker

Descarga la imagen más reciente:

```bash
docker pull ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Después, ejecuta la sonda:

```bash
docker run --detach \
  --name ripe-atlas \
  --restart unless-stopped \
  --volume ~/ripe-atlas/probe--etc--ripe-atlas:/probe/etc/ripe-atlas \
  --volume ~/ripe-atlas/probe--var--run--ripe-atlas--status:/probe/var/run/ripe-atlas/status \
  --mount type=tmpfs,destination=/probe/var/spool/ripe-atlas/data \
  ghcr.io/vitokosk8/ripe-atlas-alpine:latest
```

Comprueba si el contenedor está en marcha con `docker ps`, o revisa sus logs con:

```bash
docker logs ripe-atlas
```

La primera ejecución creará el directorio con la configuración de la sonda y la clave SSH.

Usa la clave pública `probe_key.pub` para registrar tu sonda aquí:

https://atlas.ripe.net/apply/swprobe/

## Docker Compose

Este es un ejemplo mínimo de `docker-compose.yml`:

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

Arranca la sonda con:

```bash
docker compose up --detach --pull always
```

Consulta su estado y sus logs con:

```bash
docker compose ps
docker compose logs
```

Los directorios de configuración y de estado de la sonda se guardan fuera del contenedor, mientras que los datos de medición se almacenan en un sistema de ficheros temporal y se pierden al recrear el contenedor.

## Publicar desde un fork

El workflow publica en GitHub Container Registry usando el `GITHUB_TOKEN` integrado, así que no hacen falta secretos adicionales. Las ejecuciones programadas vienen desactivadas por defecto en los forks; actívalo en la pestaña Actions si quieres la comprobación diaria del upstream.
