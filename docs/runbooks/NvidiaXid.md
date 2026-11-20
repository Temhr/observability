# NvidiaXid

**What it means.** The NVIDIA driver logged an Xid fault (`NVRM: Xid`) on this host within the last 5 minutes.

**What fires it.** Severity `warning`, category `hardware`, checklist section I.1. A Loki-ruler alert: it counts kernel journal lines containing `NVRM: Xid` over 5 minutes and fires when the count is above 0. It clears about 5 minutes after the last line. It exists only on hosts where the NVIDIA integration is enabled (`services.observability.integrations.nvidia.enable`), and it does not appear in Prometheus' `ALERTS` series.

**Likely causes.**
1. A GPU application crashed or misbehaved (Xid 13, 31, 43 and 45 are most often application or driver faults, not hardware).
2. A driver or kernel mismatch, typically right after an upgrade before a reboot.
3. Hardware: overheating, insufficient power, a badly seated card, or a failing GPU or its memory (Xid 79 "fell off the bus", Xid 48 double-bit ECC error, Xid 63/64 ECC page retirement or row remap).

**First three commands.**
1. `journalctl -k --since "-1h" | grep -iE -B1 -A2 'NVRM: Xid'` — the Xid number, the PCI address, and usually the `pid` and process `name` that triggered it.
2. `nvidia-smi` — if it errors ("couldn't communicate with the NVIDIA driver", "Driver/library version mismatch") or hangs, the driver or the GPU is not usable. If it works, also run `nvidia-smi -q -d ECC,TEMPERATURE,POWER | less`.
3. `lspci -nn | grep -i nvidia; systemctl --failed` — whether the GPU is still visible on the bus, and which GPU-using services have failed.

**Fix.** Look the Xid number up in NVIDIA's Xid error documentation to see whether it is an application error or a hardware one. For an application fault, restart the service named in step 1 and update or fix that workload. After a driver or kernel upgrade, reboot so the loaded kernel module matches the installed driver, and if the problem started with the upgrade, boot the previous generation (`nixos-rebuild switch --rollback`) and pin the earlier `hardware.nvidia.package`. For heat or power problems, clean the cooling, check the power connectors, and watch the temperatures in step 2. For hardware Xids, reseat the card and, if it recurs, replace it.

**Escalate when.** The code is 79 (GPU fell off the bus), 48 or 63/64 (ECC); it recurs after a reboot; the GPU disappears from `lspci` or `nvidia-smi`; the machine hangs or reboots; or several different Xid codes appear in a short time.

**Related alerts.** `SystemdServiceFailed` and `ServiceDown` (a GPU workload that crashed), `HighCPUTemperature` and `CPUThrottling` (a thermal problem usually shows up on more than the GPU), `NVMeCriticalWarning` or other hardware-section alerts on the same host.
