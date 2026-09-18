# tmux server wedge in the devcontainer

A tmux session inside the devcontainer becomes unusable: mouse movement injects escape-sequence garbage, then `tmux attach` hangs forever. This is two separate faults chained together, neither of which is a crash.

Diagnosed 2026-09-18 on the `web` devcontainer.

## Symptoms

- Output becomes jumbled; moving the mouse or scrolling prints garbage such as `65;83;48M`.
- Keyboard input stops doing anything useful.
- After closing the terminal window, `tmux attach`, `tmux list-sessions` and even `tmux display -p` all hang indefinitely.

## Fault 1 — stuck mouse tracking

`65;83;48M` is the tail of an SGR mouse report: `ESC [ < 65 ; 83 ; 48 M`, where `65` is scroll-down, `83` the column and `48` the row.

A process enabled mouse reporting (`DECSET 1002`/`1003` for motion and button events, plus `1006` for SGR encoding) and died without emitting the disable sequences. The terminal keeps reporting every mouse event as input text, which also desynchronizes tmux's input parser — hence the dead keyboard.

Playwright's Chromium is the leading suspect: the container holds `chrome_crashpad` zombies, and `crashpad` means abnormal termination rather than clean exit. **Not yet confirmed.** To confirm next time it happens live, run `cat -v` in a scratch pane and move the mouse; that shows whether the sequences originate from the container's tty or the outer host terminal, which determines where the permanent fix belongs.

## Fault 2 — the wedge (this is what makes attach hang)

Closing the terminal window while a tmux client is attached leaves the client orphaned — reparented to PID 1, still holding the pty slave open. Because tmux clients hand their tty fd to the server over the control socket, the **server** is the process reading that terminal. It ends up parked in a blocking `readv()` on it.

A tmux server is single-threaded. Parked in that read, it never services its control socket, so every client command hangs. The server is alive and deaf, not crashed.

Normally, closing a window collapses the pty master, the read returns `EIO`, and the client exits. That does not happen here: the master stays open on the host side (containerd-shim or the VS Code pty host), so the read blocks forever.

### Confirming it

```bash
P=$(pgrep -f 'tmux.*new-session|tmux: server' | head -1)
cat /proc/$P/wchan      # n_tty_read  -> blocked on a tty
cat /proc/$P/syscall    # 65 0x7      -> readv() on fd 7 (arm64: 63=read 64=write 65=readv)
ls -l /proc/$P/fd/7     # -> /dev/pts/N, the dead client's terminal
```

An 8-second `strace -p $P` showing **zero** syscalls confirms it is hard-blocked in one read rather than spinning.

`ps -eo pid,ppid,stat,tty,wchan:20,args` then shows the two orphans to remove: the `tmux ... attach-session` client with `PPID 1`, and the session-leader `zsh` on that same pts with `PPID 0`.

## Recovery

Run from a fresh `docker exec` shell, outside tmux. **Do not start with `kill-server`** — it takes every long-running process in those panes with it.

```bash
fuser -v /dev/pts/N              # lists everything still holding that tty

kill -9 <orphaned-attach-client-pid>
kill -9 <dead-session-leader-zsh-pid>

tmux list-sessions               # returns instantly once the read is released
```

Killing the orphans leaves the server as the sole holder of the pts and lets the pending `readv` return. This recovers the server with all panes intact.

Then attach to a **fresh** window — redrawing the flooded one is what stalls the client:

```bash
tmux set -g mouse off
tmux new-window -t <session>

stty sane
printf '\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[?1015l\033[?25h'
tmux -u attach -t <session>
```

`tmux clear-history -t <pane>` drops a pane's scrollback if the flood is still buffered in it. Re-enable with `tmux set -g mouse on` once things look right.

### What does not work

- **`SIGWINCH`, `SIGCHLD`, `SIGCONT`, `SIGUSR1`, `SIGUSR2`** — all swallowed by `SA_RESTART`; the read simply restarts.
- **`TIOCSTI` injection** — returns `EPERM` unless the target pts is the calling process's controlling terminal. Claiming it via `setsid()` + `TIOCSCTTY` fails too when the caller is already a process-group leader.

### Last resort

```bash
for p in $(tmux list-panes -a -F '#{pane_id}'); do
  tmux capture-pane -p -S -10000 -t $p > /tmp/pane$p.txt
done
tmux kill-server
```

## Prevention

Applied in `devpod/compose.override.yaml`:

1. **`init: true`** on `rails-app`. PID 1 in this container is `sleep infinity` (from `command: sleep infinity`), which never calls `wait()`. Nothing reaps orphans — the container had 309 zombies when this was diagnosed, including six `tmux` and twelve `chrome`/`chrome_crashpad`. This is the structural defect behind fault 2.
2. **`shm_size: '2gb'`** on `rails-app`. `/dev/shm` defaults to 64MB, and Playwright drives a container-local Chromium (`~/.cache/ms-playwright/chromium-*`), not only the separate selenium `chrome` service whose own `shm_size` is already set in `compose.yaml`. Chromium hard-kills on a small `/dev/shm`, which is what leaves mouse tracking enabled.

Habits:

3. **Detach with `prefix + d` before closing a terminal window.** Closing on an attached client is the trigger for fault 2. Costs nothing, avoids the whole incident.
4. Never let Playwright write to the tty: `npx playwright test > /tmp/pw.log 2>&1`, or give it its own disposable tmux window.
5. Keep an `unstick` alias to clear stuck tracking without touching tmux, so closing the window is never the reflex:

   ```bash
   alias unstick='printf "\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[?1015l\033[?25h"; stty sane; tput reset'
   ```
