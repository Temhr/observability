# ADR-008: Network exposure policy

- **Status:** Accepted (2026-11-17)
- **Related:** ADR-005

## Context

The stack binds every service to loopback unless told otherwise. Exposure is controlled by `access.expose` (which services) and `access.interfaces` (on which interfaces), producing interface-scoped firewall rules. A broader legacy option, `openFirewall`, opens ports on all interfaces. nixlab fills `access.interfaces` from its host metadata (`[ethIface wifiIface]` on desktops, `[ethIface]` on NAS hosts), and a missing Wi-Fi device can yield an empty interface name.

## Decision

1. **Loopback by default.** Importing or enabling the stack exposes nothing off-host.
2. **Four concepts stay separate and independently settable:** bind address (what the service listens on), firewall opening (who may connect), advertised address (`publicHost`: what clients are told), and reverse proxy/TLS (`domain`, `enableSSL`).
3. **Interface-scoped exposure is the supported mechanism.** `access.interfaces` names the interfaces; `access.expose` names the services. Rules are additive and never opened on interfaces the consumer did not name.
4. **`openFirewall` (all interfaces) remains for compatibility but is documented as discouraged.**
5. **Invalid input is rejected, not guessed at.** Empty interface names fail evaluation with an actionable message. Cleaning interface data is the consumer's job.
6. **The stack does not manage host networking** (DNS, gateways, NTP, interface naming) and does not assume any particular interface exists.

## Alternatives considered

- **Silently filter empty interface names in the stack.** Rejected: hides consumer data bugs and makes the firewall depend on guesswork.
- **Remove `openFirewall`.** Deferred: compatibility; revisit at 1.0.
- **Stack never touches the firewall.** Rejected for now: the interface-scoped rules are the safest way to expose services and are derived from resolved ports.

## Consequences

- Consumers with optional interfaces (laptops) must filter before passing names.
- Remote access is always an explicit, narrow opt-in.

## Migration implications

0.2 adds the empty-name assertion. If any host currently produces an empty-named firewall interface, its profile must filter it; that is the only expected parity difference.
