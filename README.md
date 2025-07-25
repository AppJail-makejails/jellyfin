# Jellyfin

Jellyfin is a free and open-source media server and suite of multimedia applications designed to organize, manage, and share digital media files to networked devices. Jellyfin consists of a server application installed on a machine running Microsoft Windows, macOS, Linux, FreeBSD, a Docker container or a FreeBSD jail, and another application running on a client device such as a smartphone, tablet, smart TV, streaming media player, game console or in a web browser. Jellyfin also can serve media to DLNA and Chromecast-enabled devices. It is a fork of Emby.

wikipedia.org/wiki/Jellyfin

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Jelly-banner-light.svg/1024px-Jelly-banner-light.svg.png" width="30%" height="auto">

## How to use this Makejail

```
INCLUDE options/network.makejail
INCLUDE gh+AppJail-makejails/jellyfin

OPTION template=files/jellyfin.conf

CMD --local mkdir -p ${PWD}/media
MOUNT ${PWD}/media /media
CMD chown -R jellyfin:jellyfin /media
```

Where `options/network.makejail` are the options that suit your environment, for example:

```
ARG ext_if
ARG iface=jellyfin
# Recommended to allow IP reservation on your router.
ARG macaddr=58-9c-fc-00-00-01

OPTION macaddr=sb_${iface}:${macaddr}
OPTION bridge=iface:${ext_if} ${iface}
OPTION dhcp=sb_${iface}
```

The `files/jellyfin.conf` template is as follows:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
mount.devfs
allow.mlock
devfs_ruleset: 14
```

A generic ruleset that allows Jellyfin to run smoothly is as follows:

```
[devfsrules_jellyfin=14]
add include $devfsrules_hide_all
add include $devfsrules_unhide_basic
add include $devfsrules_unhide_login

# DHCP
add path 'bpf*' unhide

# 3D support
add path 'dri' unhide
add path 'dri/*' unhide
add path 'drm' unhide
add path 'drm/*' unhide
add path 'pci' unhide
```

Remember to restart `devfs`:

```sh
service devfs restart
```

Open a shell and run `appjail makejail`:

```sh
appjail makejail -j jellyfin -- --ext_if jext
```

### Arguments

* `jellyfin_tag` (default: `13.5`): see [#tags](#tags).
* `jellyfin_ajspec` (default: `gh+AppJail-makejails/jellyfin`): Entry point where the `appjail-ajspec(5)` file is located.

### Volumes

| Name         | Owner | Group | Perm | Type | Mountpoint        |
| ------------ | ----- | ----- | ---- | ---- | ----------------- |
| jellyfin-db  | 868   | 868   |  -   |  -   | /var/db/jellyfin  |

## Tags

| Tag        | Arch    | Version        | Type   |
| ---------- | ------- | -------------- | ------ |
| `13.5`     | `amd64` | `13.5-RELEASE` | `thin` |
| `14.3`     | `amd64` | `14.3-RELEASE` | `thin` |
