# SSHAuthFailureBurst

**What it means.** More than 20 failed SSH authentication attempts reached this host within 10 minutes.

**What fires it.** Severity `warning`, category `security`, checklist section IV.10. A Loki-ruler alert: it counts journal lines from `sshd.service` matching `Failed password`, `Invalid user` or `authentication failure` over 10 minutes and fires when the count is above 20. It clears about 10 minutes after the burst ends. It does not appear in Prometheus' `ALERTS` series.

**Likely causes.**
1. Internet bots scanning port 22: by far the most common cause when SSH is reachable from outside your network.
2. A misconfigured client or automation (a backup job, a Git remote, a monitoring check) retrying with a wrong key or password.
3. A real brute-force or credential-stuffing attempt against known user names.

**First three commands.**
1. `journalctl -u sshd --since "-30min" | grep -E 'Failed password|Invalid user|authentication failure' | tail -50` — which users are being tried and how fast.
2. `journalctl -u sshd --since "-30min" -o cat | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -rn | head` — the top source addresses (IPv4 only; look at the raw lines for IPv6). One internal address usually means a misconfigured client; many external addresses mean scanning.
3. `journalctl -u sshd --since "-1h" | grep 'Accepted'; last -n 20` — whether anyone **logged in successfully** around the same time. This is the question that matters.

**Fix.** If it is a misconfigured client, fix its key or password and the noise stops. If it is internet noise, stop exposing SSH to the internet: restrict port 22 to your LAN or VPN with the firewall, disable password logins (`services.openssh.settings.PasswordAuthentication = false;`, `KbdInteractiveAuthentication = false;`, `PermitRootLogin = "no";`), and optionally enable `services.fail2ban.enable = true;` to ban repeat offenders. Make the change in the host or profile where your SSH service is configured, rebuild, then re-check step 1.

**Escalate when.** Step 3 shows an `Accepted` login from an address or user you do not recognise, any successful root login, failures against a real account that still allows password authentication, the burst continues after you have restricted access, or several hosts report it at the same time.

**Related alerts.** The same alert on other hosts during a network-wide scan; `HighCPULoad` if the attempts are heavy enough to load the machine.
