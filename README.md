# openrig-herdr

Lays out OpenRig rigs in [herdr](https://herdr.dev) the way I want to read them:

- **Tab 1:** the rig's primary point of contact, alone. That's the first member of the first pod; for the
  kernel, the operator.
- **Tab 2:** the other members of that first pod, if any.
- **Then one tab per pod**, in spec order, with its members as panes (side by side, or a grid for four).

OpenRig's own `rig terminal open` fills tabs nine panes at a time and has no per-pod option, so this
repo does it from the herdr side. Seats are never restarted: existing panes are moved, and a seat
without a pane gets one attached to its tmux session.

## Install

```sh
git clone git@github.com:DaazKu/openrig-herdr ~/projects/openrig-herdr
~/projects/openrig-herdr/install.sh
```

Needs `rig`, `herdr`, `tmux` and `python3` with PyYAML. The installer links both scripts into
`~/.local/bin` and starts the watcher as a `systemd --user` service. It's safe to rerun, for example
after moving node or OpenRig.

## What's in it

- **`rig-herdr-layout <rig> [<rig> ...]`** lays out a rig's space now. It opens the space first if
  there isn't one. The rig name is the RIG column of `rig ps`.
- **`rig-herdr-watch`** (the service) listens to herdr's event stream. When a space in OpenRig's
  default layout appears and has been quiet for a few seconds, it runs `rig-herdr-layout` on it. A
  layout runs once per space; spaces already laid out are left alone.

## Good to know

- Once laid out, a space loses OpenRig's tab marker, so a later `rig terminal open <rig>` opens a
  second space. The watcher lays that one out too; close whichever you don't need (closing a space
  only detaches the viewers, the agents keep running).
- Logs: `journalctl --user -u rig-herdr-watch -f`
- Turn it off: `systemctl --user disable --now rig-herdr-watch`
