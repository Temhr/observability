<h1>NixOS Observability</h1>

A modular, declarative and self-contained observability stack for NixOS, distributed as an independent Nix flake.

<h2>Overview</h2>

This repository provides reusable NixOS modules for deploying and managing an integrated observability stack. It is designed to be consumed by other NixOS flakes while remaining independently configurable, testable and maintainable.

The stack brings together:

<strong>Prometheus</strong> — Metrics collection, monitoring and alerting.
<strong>Grafana</strong> — Dashboards and visualisation.
<strong>Loki</strong> — Log aggregation and querying.
<strong>Alloy</strong> — Metrics and log collection.
<strong>Alertmanager</strong> — Alert routing and notifications.
<strong>ntfy</strong> — Notification delivery.

It also provides shared configuration, service integration, dashboards, alert rules, operational scripts, runbooks and validation.

<h2>Design principles</h2>

<strong>Declarative:</strong> Configuration and infrastructure are defined through NixOS modules.
<strong>Modular:</strong> Services can be enabled and configured independently or composed as a complete stack.
<strong>Self-contained:</strong> Required helpers, defaults, options and integration logic are maintained within this repository.
<strong>Decoupled:</strong> No dependency on consumer-specific host metadata, users, networking or internal libraries.
<strong>Composable:</strong> Public modules and options provide explicit integration points for consuming flakes.
<strong>Idempotent:</strong> Repeated evaluation and deployment produce consistent system configuration.
<strong>Secure by default:</strong> Service hardening, permissions and network exposure follow explicit security policies.
<strong>Testable:</strong> Configuration generation, alert rules, dashboards and integrations are validated independently.

<h2>Architecture</h2>

The repository owns the observability implementation and its operational lifecycle.
<figure class="table">
  <table>
    <tbody>
      <tr>
        <th>Responsibility</th>
        <th>Ownership</th>
      </tr>
      <tr>
        <th>Service modules and configuration</th>
        <th>This repository</th>
      </tr>
      <tr>
        <th>Stack aggregation and service integration</th>
        <th>This repository</th>
      </tr>
      <tr>
        <th>Shared helpers and defaults</th>
        <th>This repository</th>
      </tr>
      <tr>
        <th>Dashboards, alerts and runbooks</th>
        <th>This repository</th>
      </tr>
      <tr>
        <th>Operational scripts and validation</th>
        <th>This repository</th>
      </tr>
      <tr>
        <th>Host identity and machine metadata</th>
        <th>Consumer</th>
      </tr>
      <tr>
        <th>User and group policy</th>
        <th>Consumer</th>
      </tr>
      <tr>
        <th>Network topology and firewall policy</th>
        <th>Consumer</th>
      </tr>
      <tr>
        <th>Storage provisioning and backup destinations</th>
        <th>Consumer</th>
      </tr>
      <tr>
        <th>Encrypted secrets and age identities</th>
        <th>Consumer</th>
      </tr>
      <tr>
        <th>Host profiles and deployment policy</th>
        <th>Consumer</th>
      </tr>
    </tbody>
  </table>
</figure>

The public interface is defined through exported flake outputs and documented NixOS options. Internal implementation details should not be required by consumers.

<h2>Usage</h2>

Add this repository as a flake input and import the desired exported NixOS modules into your system configuration.

The stack is disabled by default. Consumers decide which services or integrations to enable and provide host-specific configuration through the public options.

A consuming flake may provide thin adapter modules to translate its own host metadata, port assignments, user policy and network configuration into the observability interface.

See <a href="docs/operations/installation.md">Installation</a> and <a href="docs/architecture/public-api.md">Public API</a>.

<h2>Repository structure</h2>

The repository is organised around independently maintained NixOS modules, shared internals, flake composition and supporting operational assets.

<code>flake/</code> — Flake composition, outputs and development tooling.
<code>modules/</code> — NixOS service modules and stack integration.
<code>lib/</code> — Internal helper functions.
<code>config/</code> — Dashboards, alert rules and service assets.
<code>scripts/</code> — Operational and maintenance utilities.
<code>tests/</code> — Evaluation, configuration and integration tests.
<code>docs/</code> — Architecture, operations, development guides and runbooks.

<h2>Development and validation</h2>

The repository maintains its own development environment and CI checks.

Validation should cover:

Flake evaluation and module composition.

* Individual service and full-stack configurations.
* Rendered service configuration.
* Prometheus and Alertmanager rules.
* Dashboard provisioning and consistency.
* Optional integrations and feature combinations.
* Operational scripts and runbook coverage.
* Compatibility with supported nixpkgs versions.

See <a href="docs/development/testing.md">Testing</a>.

<h2>Documentation</h2>

<a href="docs/architecture/overview.md">Architecture overview</a>

<a href="docs/architecture/module-boundaries.md">Module boundaries</a>

<a href="docs/architecture/public-api.md">Public API</a>

<a href="docs/architecture/security-model.md">Security model</a>

<a href="docs/operations/installation.md">Installation</a>

<a href="docs/operations/backup-restore.md">Backup and restore</a>

<a href="docs/operations/troubleshooting.md">Troubleshooting</a>

<a href="docs/development/adding-a-component.md">Adding a component</a>

<a href="docs/runbooks/">Runbooks</a>

<h2>Compatibility and releases</h2>

The repository is independently versioned. Consumers should pin a release or commit through their flake lock file.

Public module names, option definitions, persistent state paths, service identities and secret interfaces are treated as compatibility contracts. Breaking changes should be documented with migration guidance.
<hr>

<strong>Objective:</strong> Provide a cohesive, reusable and independently maintained observability platform for NixOS without coupling its implementation to the infrastructure that consumes it.
