#!/usr/bin/env bash
# Link the scripts into ~/.local/bin and start the watcher as a user service.
# Safe to rerun. Uninstall: systemctl --user disable --now rig-herdr-watch
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)
bin=$HOME/.local/bin
unit_dir=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user

for tool in rig herdr tmux python3; do
    command -v "$tool" >/dev/null || { echo "install.sh: $tool not found on PATH" >&2; exit 1; }
done
python3 -c 'import yaml' 2>/dev/null || { echo "install.sh: python3 needs PyYAML (python3-yaml)" >&2; exit 1; }

mkdir -p "$bin" "$unit_dir"
for script in rig-herdr-layout rig-herdr-watch; do
    ln -sfn "$repo/bin/$script" "$bin/$script"
    echo "linked $bin/$script"
done

# The service gets no login shell, so give it the directories of the tools it calls.
# Skip OpenRig's per-seat shims (~/.openrig/run/seat-bin) when run from an agent seat.
real() { type -ap "$1" | grep -v '/.openrig/run/' | head -1; }
path=$bin
for tool in rig node herdr tmux; do
    found=$(real "$tool")
    [ -n "$found" ] || { echo "install.sh: $tool not found outside OpenRig seat shims" >&2; exit 1; }
    dir=$(dirname "$found")
    case ":$path:" in *":$dir:"*) ;; *) path=$path:$dir ;; esac
done
path=$path:/usr/local/bin:/usr/bin:/bin

sed -e "s#@PATH@#$path#" -e "s#@BIN@#$bin#" "$repo/systemd/rig-herdr-watch.service" \
    > "$unit_dir/rig-herdr-watch.service"
systemctl --user daemon-reload
systemctl --user enable --now rig-herdr-watch.service
systemctl --user restart rig-herdr-watch.service
echo "rig-herdr-watch is $(systemctl --user is-active rig-herdr-watch.service)"
echo "logs: journalctl --user -u rig-herdr-watch -f"
