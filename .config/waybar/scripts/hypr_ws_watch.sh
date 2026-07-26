#!/usr/bin/env python3
"""Watch Hyprland workspace events, cache state for the waybar ws_button modules.

Waybar 0.15.0's hyprland/workspaces module hardcodes the pre-Lua
`dispatch workspace <id>` IPC string, which Hyprland >=0.55 rejects, so its
buttons no longer switch workspaces (Alexays/Waybar#5008). The workspace row is
built from custom/wsN modules instead; this process feeds them.

This exists only for that workaround - see the revert notes in config.jsonc and
delete this script once the native module works again.

On every workspace-affecting event it rewrites the state file and then raises
SIGRTMIN+5 on waybar. Writing before signalling is what keeps the button
scripts from reading a stale file.

State file format, one line per existing workspace:  <id>\t<active|occupied>
"""

import fcntl
import json
import os
import signal
import socket
import subprocess
import sys

RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
STATE_PATH = os.path.join(RUNTIME, "waybar-workspaces.state")
WAYBAR_SIGNAL = 5  # matches "signal": 5 on the custom/wsN modules

# Events that can change which workspaces exist, which is active, or whether a
# workspace still holds windows.
WATCHED = {
    "workspace", "workspacev2",
    "createworkspace", "createworkspacev2",
    "destroyworkspace", "destroyworkspacev2",
    "moveworkspace", "moveworkspacev2",
    "focusedmon", "focusedmonv2",
    "openwindow", "closewindow",
    "movewindow", "movewindowv2",
    "activespecial", "activespecialv2",
    "configreloaded",
}


def socket_dir():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not sig:
        sys.exit("HYPRLAND_INSTANCE_SIGNATURE unset - not running under Hyprland")
    return os.path.join(RUNTIME, "hypr", sig)


def query(command):
    """Run a socket1 request ourselves rather than spawning hyprctl per event."""
    with socket.socket(socket.AF_UNIX) as sock:
        sock.connect(os.path.join(socket_dir(), ".socket.sock"))
        sock.sendall(command.encode())
        chunks = []
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                break
            chunks.append(chunk)
    return json.loads(b"".join(chunks).decode("utf-8", "replace"))


def refresh():
    try:
        workspaces = query("j/workspaces")
        active = query("j/activeworkspace").get("id")
    except (OSError, ValueError):
        return  # Hyprland restarting or mid-reload; the next event retries

    lines = []
    for ws in workspaces:
        wid = ws.get("id")
        if not isinstance(wid, int) or wid < 1:
            continue  # skip special/scratchpad workspaces (negative ids)
        lines.append(f"{wid}\t{'active' if wid == active else 'occupied'}")

    tmp = f"{STATE_PATH}.tmp"
    with open(tmp, "w", encoding="utf-8") as handle:
        handle.write("\n".join(sorted(lines)) + "\n")
    os.replace(tmp, STATE_PATH)  # atomic: readers never see a partial file

    subprocess.run(["pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "waybar"],
                   check=False, stderr=subprocess.DEVNULL)


def acquire_lock():
    """Serialise instances, because waybar does not reap this child when it
    reloads its config (SIGUSR2) and so leaves an extra copy behind.

    A duplicate *blocks* here rather than exiting: exiting would trip waybar's
    restart-interval into respawning it every few seconds, and killing the older
    copy just makes the two take turns evicting each other. Parked on the lock it
    costs nothing, keeps its stdout open so waybar stays satisfied, and takes over
    automatically if the active instance dies."""
    fd = os.open(os.path.join(RUNTIME, "waybar-workspaces.lock"),
                 os.O_CREAT | os.O_RDWR, 0o600)
    fcntl.flock(fd, fcntl.LOCK_EX)  # blocking
    return fd  # held for the process lifetime; released implicitly on exit


def main():
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    acquire_lock()
    refresh()  # seed the file so buttons render before the first event

    with socket.socket(socket.AF_UNIX) as sock:
        sock.connect(os.path.join(socket_dir(), ".socket2.sock"))
        buffered = b""
        while True:
            chunk = sock.recv(8192)
            if not chunk:
                break  # Hyprland went away; waybar's restart-interval re-execs us
            buffered += chunk
            *complete, buffered = buffered.split(b"\n")
            if any(line.split(b">>", 1)[0].decode("utf-8", "replace") in WATCHED
                   for line in complete):
                refresh()


if __name__ == "__main__":
    main()
