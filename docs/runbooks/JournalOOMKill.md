# JournalOOMKill

**What it means.** The kernel's out-of-memory killer terminated a process on this host within the last 5 minutes.

**What fires it.** Severity `critical`, category `os`, checklist section II.5. A Loki-ruler alert: it counts kernel journal lines (`{job="systemd-journal", transport="kernel"}`) matching `out of memory: kill` or `oom-kill` over 5 minutes and fires as soon as the count is above 0 (no `for` delay). It clears about 5 minutes after the last matching line. Loki-ruler alerts go Loki → Alertmanager → ntfy and do **not** appear in Prometheus' `ALERTS` series, so they are absent from the dashboard's alert tables.

**Likely causes.**
1. One service leaked memory or hit a spike (large model, build, browser, database query) and the machine ran out of RAM and swap.
2. A unit hit its own memory limit (`MemoryMax=`): the kernel log then says "Memory cgroup out of memory", and only that unit is killed.
3. Too little RAM or swap for the normal workload (several memory-hungry services together).

**First three commands.**
1. `journalctl -k --since "-30min" | grep -iE 'out of memory|oom-kill|killed process'` — names the victim (`Killed process <pid> (<name>)`), the cgroup it belonged to, and whether the host or a unit limit triggered it.
2. `free -h; swapon --show; systemd-cgtop -m --iterations=1 --batch | head -15` — current memory and swap, and which units hold the memory now.
3. `systemctl --failed; journalctl -u <victim-unit> --since "-30min" | tail -50` — whether the killed service stayed down, restarted, or is looping.

**Fix.** Identify the hog (command 2) and cap or reduce it: set `systemd.services.<name>.serviceConfig.MemoryMax` (and `MemoryHigh` below it) on the offending unit in your NixOS configuration, so a runaway unit is killed instead of the whole host; reduce its workload or model size; enable compressed swap (`zramSwap.enable = true`) or add RAM. If the victim was a service you need, restart it and confirm with `systemctl status`.

**Escalate when.** It recurs within hours, the victim is a critical service (sshd, a database, the monitoring stack itself), no single hog is visible, the host becomes unresponsive, or the kernel log also shows memory hardware errors (ECC, `Hardware Error`, `mce`).

**Related alerts.** `OutOfMemoryKills` (Prometheus: the same event seen through `node_vmstat_oom_kill`, 1-hour window), `HighMemoryUsage`, `SwapUsage`, `HighIOWait`, `SystemdServiceFailed`, `ServiceDown`.
