# Jellyfin

Jellyfin is a free and open-source media server and suite of multimedia applications designed to organize, manage, and share digital media files to networked devices. Jellyfin consists of a server application installed on a machine running Microsoft Windows, macOS, Linux, FreeBSD, a Docker container or a FreeBSD jail, and another application running on a client device such as a smartphone, tablet, smart TV, streaming media player, game console or in a web browser. Jellyfin also can serve media to DLNA and Chromecast-enabled devices. It is a fork of Emby.

wikipedia.org/wiki/Jellyfin

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Jellyfin-horizontal--color-on-light.svg/1280px-Jellyfin-horizontal--color-on-light.svg.png" width="30%" height="auto" alt="Jellyfin logo">

## How to use this Makejail

### Deploy Jellyfin using Virtual Networks

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    -o expose="8096" \
    -o expose="7359 proto:udp" \
    -o fstab="/path/to/config /var/db/jellyfin" \
    -o fstab="/path/to/cache /var/cache/jellyfin" \
    -o fstab="/path/to/media /media" \
    ghcr.io/appjail-makejails/jellyfin jellyfin
```

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
mount.devfs
persist
allow.mlock
```
### Deploy Jellyfin using Host Networking

The example above uses [Virtual Networks](https://appjail.readthedocs.io/en/latest/networking/virtual-networks/intro/). Using [host networking](https://appjail.readthedocs.io/en/latest/networking/ip-inherit/) (`-o alias -o ip4_inherit -o ip6_inherit`) is optional but required in order to use DLNA.

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o alias \
    -o ip4_inherit \
    -o ip6_inherit \
    -o template=template.conf \
    -o expose="8096" \
    -o expose="7359 proto:udp" \
    -o fstab="/path/to/config /var/db/jellyfin" \
    -o fstab="/path/to/cache /var/cache/jellyfin" \
    -o fstab="/path/to/media /media" \
    ghcr.io/appjail-makejails/jellyfin jellyfin
```

### Deploy using `appjail-director` (+hardware acceleration)

```yaml
options:
  - alias:
  - ip4_inherit:
  - ip6_inherit:

services:
  jellyfin:
    name: jellyfin
    makejail: gh+AppJail-makejails/jellyfin
    options:
      - template: !ENV '${PWD}/template.conf'
      - mount_devfs:
      - device: "path dri unhide"
      - device: "path 'dri/*' unhide"
      - device: "path drm unhide"
      - device: "path 'drm/*' unhide"
      - device: "path pci unhide"
      - device: "path 'nvidia*' unhide"
    volumes:
      - config: /var/db/jellyfin
      - cache: /var/cache/jellyfin
      - media: /media
    oci:
      # Optional - alternative address used for autodiscovery
      environment:
        - JELLYFIN_PublishedServerUrl: http://example.com

volumes:
  config:
    device: /var/appjail-volumes/jellyfin/config
  cache:
    device: /var/appjail-volumes/jellyfin/cache
  media:
    device: /path/to/media
```

Since the previous example uses the host networking, you can access Jellyfin via `http://localhost:8096` or your host's IP address.

### Arguments (stage: build)

* `jellyfin_from` (default: `ghcr.io/appjail-makejails/jellyfin`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `jellyfin_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-d5250a148a-var_cache_jellyfin | `${PUID}` | `${PGID}` | - | - | /var/cache/jellyfin |
| appjail-dcc8a6f9f1-var_db_jellyfin | `${PUID}` | `${PGID}` | - | - | /var/db/jellyfin |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        JELLYFIN_FFMPEG_VERSION: "7"
        FREEBSD_RELEASE: "15.1"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```

## Notes

1. The ideas present in the Docker image of Jellyfin are taken into account for users who are familiar with it.
2. [jellyfin-ffmpeg](https://github.com/daemonless/jellyfin-ffmpeg) is used instead of [ffmpeg](https://www.freshports.org/multimedia/ffmpeg).
