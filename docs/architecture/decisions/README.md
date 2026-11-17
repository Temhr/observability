# Architecture decision records

Short records of decisions that shape the public interface. Format: Status, Context, Decision, Alternatives considered, Consequences, Migration implications.

Rules:
- One decision per file. Never edit an accepted ADR's *Decision*; supersede it with a new ADR and update the old one's status line.
- Cite ADRs from code comments and commit messages (`see ADR-005`).
- Numbers follow the design document's list, so gaps are intentional (001, 002, 004, 007, 010-012 are written later or in Guide 3).

| ADR | Title | Status |
|---|---|---|
| [003](ADR-003-module-namespace.md) | Module and option namespace | Accepted |
| [005](ADR-005-host-integration.md) | Host integration contract | Accepted |
| [006](ADR-006-helper-ownership.md) | Helper ownership | Accepted |
| [008](ADR-008-exposure.md) | Network exposure policy | Accepted |
| [009](ADR-009-secrets.md) | Secrets integration | Accepted |
