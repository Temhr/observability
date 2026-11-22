## services\.observability\.enable



Whether to enable nixlab observability stack (Prometheus + Loki + Grafana + Alertmanager + ntfy)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.access\.expose



Which services to open on access\.interfaces\.



*Type:*
list of (one of “grafana”, “ntfy”, “alertmanager”, “prometheus”, “loki”)



*Default:*

```nix
[
  "grafana"
  "ntfy"
  "prometheus"
]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.access\.interfaces



Network interfaces on which the services in ` expose ` are reachable\.
Empty means loopback only\. Names must be non-empty; omit interfaces
the machine does not have\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "eno1"
]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.dataDir



Root directory; each service gets a subdirectory\.



*Type:*
string



*Default:*

```nix
"/data"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.cadvisor\.enable



Whether to enable scraping and alerting for cAdvisor container metrics\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.cadvisor\.target



host:port of the cAdvisor container metrics metrics endpoint\.



*Type:*
string



*Default:*

```nix
"127.0.0.1:8080"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.nvidia\.enable



Whether to enable the NVIDIA Xid log alert (needs the NVIDIA kernel driver)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.postgres\.enable



Whether to enable scraping and alerting for the PostgreSQL exporter\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.postgres\.target



host:port of the the PostgreSQL exporter metrics endpoint\.



*Type:*
string



*Default:*

```nix
"127.0.0.1:9187"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.traefik\.enable



Whether to enable scraping and alerting for traefik\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.integrations\.traefik\.target



host:port of the traefik metrics endpoint\.



*Type:*
string



*Default:*

```nix
"127.0.0.1:8082"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.listenAddress



Force one bind address for every service\. Null (the default) binds each
service on its own: services in access\.expose listen on 0\.0\.0\.0 when
access\.interfaces is non-empty; everything else listens on loopback\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.loki\.maintenance\.enable



Whether to enable maintenance task logging integration\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.loki\.retention



Loki log retention period (e\.g\. 744h = 31 days)\.



*Type:*
string



*Default:*

```nix
"744h"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.formatMessages



Use ntfy message templating so notifications show alert summary/description instead of raw JSON\. Requires ntfy >= 2\.10\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.ntfyAuth\.enable



Whether to enable ntfy authentication with an Alertmanager writer and a reader account (needs NTFY_\*_PASSWORD in the alertmanager secrets file)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.ntfyAuth\.environmentFile



File of KEY=VALUE lines read by ntfy-provision (NTFY_ALERTMANAGER_PASSWORD and friends)\.
Defaults to the Alertmanager environment file; both need the same credentials\.



*Type:*
null or absolute path



*Default:*

```nix
config.services.observability-alertmanager.environmentFile
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.ntfyTopic



ntfy topic that alertmanager will publish to\.



*Type:*
string



*Default:*

```nix
"alerts"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.separateCritical



Route severity=critical to a separate ntfy receiver with max priority and a warning tag\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.topics



Extra ntfy topics, published as \<ntfyTopic>-\<name> (e\.g\. alerts-storage)\.
An alert goes to every topic whose matchers it satisfies\. The catch-all
topic still receives everything unless a matching topic sets
alsoCatchAll = false\. The alertmanager and reader ntfy users are granted
access to each topic automatically\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  storage = {matchers = ["category=~\"storage|backup\""];};
  security = {matchers = ["category=\"security\""]; priority = 4;};
  urgent = {matchers = ["severity=\"critical\""]; priority = 5; alsoCatchAll = false;};
}

```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.topics\.\<name>\.alsoCatchAll



Also deliver to the catch-all topic\. False keeps matching alerts out of it\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.topics\.\<name>\.matchers



Alertmanager matchers; an alert must satisfy all of them\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "severity=\"critical\""
]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.topics\.\<name>\.priority



ntfy priority for this topic (1 min … 5 max)\. Null leaves ntfy’s default\.



*Type:*
null or integer between 1 and 5 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.topics\.\<name>\.tags



ntfy tags (emoji shortcodes) added to messages on this topic\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.notifications\.useNtfy



Wire alertmanager to send alerts to the local ntfy instance via a
webhook receiver\. Set to false to define your own alertmanager
receivers (Slack, PagerDuty, etc\.) instead — see
services\.observability-alertmanager\.receivers on the host config\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.ntfy\.cachePersist



Persist ntfy message cache to disk (survives restarts)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.openFirewall



Open each service’s port on every interface (the old behaviour)\.
Prefer access\.interfaces, which scopes the rules to chosen interfaces\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.probes\.gateway



Address (typically the default gateway) to ICMP-probe, or null\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"192.0.2.1"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.probes\.icmpTargets



Addresses to ICMP-probe in addition to the gateway\. This machine’s own publicHost is excluded\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "192.0.2.20"
]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.probes\.tcpTargets



host:port TCP probe targets for the blackbox exporter\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "127.0.0.1:8123"
]
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.maintenance\.enable



Whether to enable maintenance observability integration\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.maintenance\.exporters\.smartctl\.enable



Enable smartctl disk health exporter\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.maintenance\.exporters\.systemd



Enable systemd unit exporter\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.retention



Prometheus retention time\.



*Type:*
string



*Default:*

```nix
"15d"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.retentionSize



Prometheus size cap; set on laptops\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"8GB"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.prometheus\.scrapeInterval



Prometheus scrape and evaluation interval\.



*Type:*
string



*Default:*

```nix
"30s"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability\.publicHost



Host name or address that links in notifications and the UIs use\.
Set a name here (or a ` domain ` on a service) once a reverse proxy
fronts it\. Null leaves each service’s own fallback\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"192.0.2.10"
```

*Declared by:*
 - [\<nixpkgs/stacks/observability\.nix, via option flake\.nixosModules\.stack--observability>](https://github.com/NixOS/nixpkgs/blob//stacks/observability.nix, via option flake.nixosModules.stack--observability)



## services\.observability-alertmanager\.enable



Whether to enable Prometheus Alertmanager\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.enableSSL



Enable HTTPS with Let’s Encrypt (requires domain)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.package



The Alertmanager package to use



*Type:*
package



*Default:*

```nix
pkgs.prometheus-alertmanager
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.checkConfig

Validate the generated configuration with ` amtool check-config `
at build time\. Defaults to false automatically when environmentFile
is set, since the sandbox cannot read the decrypted secrets file\.
Set explicitly to override either way\.



*Type:*
boolean



*Default:*

```nix
environmentFile == null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.clusterPeers



Addresses of other Alertmanager instances to peer with for HA\.
clusterPort is used automatically\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alertmanager-2.example.com"
  "alertmanager-3.example.com"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.clusterPort



Port for Alertmanager cluster gossip communication\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9094
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.defaultReceiver



Receiver that catches all alerts not matched by a child route\.
Defaults to “null” (drop) so notification destinations are
explicitly opted into\.



*Type:*
string



*Default:*

```nix
"null"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.domain



Domain name for nginx reverse proxy (optional)



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"alertmanager.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.environmentFile



Path to a file containing KEY=VALUE pairs injected into the
Alertmanager process environment\. Intended to be set by the
companion nsops–observability-alertmanager module via sops-nix\.

When set, use $KEY references in receiver configs to keep secrets
out of the store, and set checkConfig = false\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.externalUrl



URL that links, redirects and notifications point to when no domain is set\. Null keeps the previous fallback\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"http://10.0.0.251:9093/"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.extraConfig



Raw attrset deep-merged into the generated Alertmanager config\.
Keys here take precedence over the structured options above\.
Use for fields not yet covered by this module\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.pagerdutyUrl



PagerDuty API URL override (null = upstream default)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.resolveTimeout



How long to wait before declaring an alert resolved if it stops firing\.



*Type:*
string



*Default:*

```nix
"5m"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.slackApiUrl



Global Slack incoming webhook URL\. Use a $ENV_VAR reference here
combined with environmentFile to keep the URL out of the store\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.smtpAuthUsername



SMTP authentication username\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.smtpFrom



Default SMTP From address\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"alertmanager@example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.smtpRequireTLS



Require STARTTLS for SMTP connections\. Null uses the alertmanager default (true)\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.global\.smtpSmarthost



SMTP relay host:port\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"smtp.example.com:587"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.inhibitRules



Inhibition rules that suppress target alerts when source alerts
are firing\. The default suppresses warnings when a critical fires
for the same instance and category\. A critical on one mountpoint
therefore also suppresses warnings on other mountpoints of that host\.



*Type:*
list of (submodule)



*Default:*

```nix
[
  {
    equal = [
      "instance"
      "category"
    ];
    sourceMatchers = [
      "severity=\"critical\""
    ];
    targetMatchers = [
      "severity=\"warning\""
    ];
  }
  {
    equal = [
      "instance"
    ];
    sourceMatchers = [
      "alertname=\"PrometheusNoRecentSamples\""
    ];
    targetMatchers = [
      "category=\"observability\""
      "alertname!=\"PrometheusNoRecentSamples\""
    ];
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.inhibitRules\.\*\.equal



Labels that must have identical values on both source and target
for the inhibition to apply\. An empty list means the rule fires
globally — usually not what you want\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alertname"
  "instance"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.inhibitRules\.\*\.sourceMatchers



Matchers for the source (suppressing) alert\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "severity=\"critical\""
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.inhibitRules\.\*\.targetMatchers



Matchers for the target (suppressed) alert\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "severity=\"warning\""
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.listenAddress



IP address to bind to (use 0\.0\.0\.0 for all interfaces)



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.openFirewall



Open firewall ports



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.port



Port for Alertmanager to listen on



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9093
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.receivers



Alertmanager receiver list\. Each entry must have a “name” field\.
Integration configs are specified as \<type>_configs lists on the
same attrset\.

Reference secrets as $ENV_VAR strings; inject values at runtime
via the companion nsops–observability-alertmanager sops module\.

See https://prometheus\.io/docs/alerting/latest/configuration/\#receiver



*Type:*
list of (attribute set)



*Default:*

```nix
[
  {
    name = "null";
  }
]
```



*Example:*

```nix
[
  {
    name = "null";
  }
  {
    name = "slack-warnings";
    slack_configs = [
      {
        api_url = "$SLACK_WEBHOOK_URL";
        channel = "#alerts";
        send_resolved = true;
      }
    ];
  }
  {
    name = "pagerduty-critical";
    pagerduty_configs = [
      {
        routing_key = "$PAGERDUTY_ROUTING_KEY";
        send_resolved = true;
      }
    ];
  }
  {
    name = "ntfy";
    webhook_configs = [
      {
        send_resolved = true;
        url = "http://localhost:2586/alerts";
      }
    ];
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.groupBy



Labels to group alerts by at the root of the routing tree\.



*Type:*
list of string



*Default:*

```nix
[
  "alertname"
  "instance"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.groupInterval



How long to wait before notifying about new alerts added to an existing group\.



*Type:*
string



*Default:*

```nix
"5m"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.groupWait



How long to wait before sending the first notification for a new group\.



*Type:*
string



*Default:*

```nix
"30s"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.repeatInterval



How long to wait before re-sending an already-sent notification\.



*Type:*
string



*Default:*

```nix
"4h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes



Child routes evaluated in order\. The first match wins unless
continue = true is set on the matched route\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    groupWait = "10s";
    matchers = [
      "severity=\"critical\""
    ];
    receiver = "pagerduty-critical";
    repeatInterval = "1h";
  }
  {
    matchers = [
      "severity=\"warning\""
    ];
    receiver = "slack-warnings";
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.continue



If true, continue matching subsequent sibling routes after this one matches\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.groupBy



Labels to group alerts by on this route\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alertname"
  "cluster"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.groupInterval



How long to wait before sending a notification about new alerts added to an existing group\.



*Type:*
string



*Default:*

```nix
"5m"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.groupWait



How long to wait before sending an initial notification for a new group\.



*Type:*
string



*Default:*

```nix
"30s"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.matchers



List of label matchers (UTF-8 format) that must all match for
this route to be selected\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "severity=\"critical\""
  "team=\"ops\""
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.muteTimeIntervals



Named time intervals during which notifications for this route are muted\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "weekends"
  "business-hours"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.receiver



Name of the receiver this route delivers to\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.route\.routes\.\*\.repeatInterval



How long to wait before re-sending an already-sent notification\.



*Type:*
string



*Default:*

```nix
"12h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alertmanager\.secretsFile



Path to the sops-encrypted alertmanager secrets file\.
Required when the service is enabled; supplied by the consumer (the encrypted file is not part of this repository)\.
Override per-host if needed\.

The decrypted file is rendered as KEY=VALUE pairs and injected
into the Alertmanager process environment at startup\. Reference
the keys as $KEY inside receiver configs to keep secrets out of
the Nix store\.

Example file contents (before sops encryption):
SLACK_WEBHOOK_URL=https://hooks\.slack\.com/services/T…/B…/xxx
SLACK_WEBHOOK_URL_CRITICAL=https://hooks\.slack\.com/services/T…/B…/yyy
PAGERDUTY_ROUTING_KEY=abc123
SMTP_PASSWORD=hunter2
NTFY_ALERTMANAGER_PASSWORD=supersecret
NTFY_READER_PASSWORD=supersecret



*Type:*
absolute path

*Declared by:*
 - [\<nixpkgs/sops/alertmanager\.nix, via option flake\.nixosModules\.nsops--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//sops/alertmanager.nix, via option flake.nixosModules.nsops--observability-alertmanager)



## services\.observability-alertmanager\.timeIntervals



Named time intervals used by routes to mute notifications during
specific periods (weekends, on-call hours, maintenance windows)\.
See https://prometheus\.io/docs/alerting/latest/configuration/\#time_interval



*Type:*
list of (attribute set)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    name = "weekends";
    time_intervals = [
      {
        weekdays = [
          "saturday"
          "sunday"
        ];
      }
    ];
  }
  {
    name = "business-hours";
    time_intervals = [
      {
        times = [
          {
            end_time = "18:00";
            start_time = "08:00";
          }
        ];
        weekdays = [
          "monday:friday"
        ];
      }
    ];
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alertmanager/default\.nix, via option flake\.nixosModules\.servc--observability-alertmanager>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alertmanager/default.nix, via option flake.nixosModules.servc--observability-alertmanager)



## services\.observability-alloy\.enable



Whether to enable Grafana Alloy log collector\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.package



The Grafana Alloy package to use\.



*Type:*
package



*Default:*

```nix
pkgs.grafana-alloy
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.afterLocalLoki



Order Alloy after the local loki\.service\. Set false when Loki does not run on this host\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.extraConfig



River configuration appended to the base pipelines (journal and /var/log/\*\.log)\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.extraUsers



Extra users to add to the alloy group (the main user is added automatically)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.gid



Pinned gid for the alloy group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.lokiUrl



Loki push endpoint\.



*Type:*
string



*Default:*

```nix
"http://127.0.0.1:3100/loki/api/v1/push"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.port



Port of Alloy’s HTTP server (UI, /metrics)\. Bound to loopback\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
12345
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-alloy\.uid



Pinned uid for the alloy user\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/alloy/default\.nix, via option flake\.nixosModules\.servc--observability-alloy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/alloy/default.nix, via option flake.nixosModules.servc--observability-alloy)



## services\.observability-backup\.enable



Whether to enable consistent copies of the observability stack’s state\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/observability-backup/default\.nix, via option flake\.nixosModules\.systm--observability-backup>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/observability-backup/default.nix, via option flake.nixosModules.systm--observability-backup)



## services\.observability-backup\.dir



Directory the copies are written to\. Include it in your normal backup (backup-home sources)\.



*Type:*
string



*Example:*

```nix
"/data/backup"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/observability-backup/default\.nix, via option flake\.nixosModules\.systm--observability-backup>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/observability-backup/default.nix, via option flake.nixosModules.systm--observability-backup)



## services\.observability-backup\.plainFiles



Files or directories copied as they are\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/observability-backup/default\.nix, via option flake\.nixosModules\.systm--observability-backup>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/observability-backup/default.nix, via option flake.nixosModules.systm--observability-backup)



## services\.observability-backup\.sqliteFiles



SQLite databases, copied with sqlite3 \.backup\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/observability-backup/default\.nix, via option flake\.nixosModules\.systm--observability-backup>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/observability-backup/default.nix, via option flake.nixosModules.systm--observability-backup)



## services\.observability-grafana\.enable



Whether to enable Grafana monitoring and visualization platform\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.enableSSL



Enable HTTPS with Let’s Encrypt\. Requires domain to be set\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.package



The Grafana package to use\.



*Type:*
package



*Default:*

```nix
pkgs.grafana
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.allowAnonymous



Allow anonymous read-only access to dashboards\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.credentialsFile



Path to a file containing the raw admin password (no KEY=VALUE
wrapper)\. Passed to Grafana via GF_SECURITY_ADMIN_PASSWORD__FILE\.

Note that Grafana only applies this when it first creates its
database\. To change the password of an existing instance use
` grafana cli admin reset-admin-password `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"/run/secrets/GRAFANA_ADMIN_PASSWORD"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dashboards



Module-owned dashboards provisioned on every host that enables this
service\. To add host-specific dashboards without touching this set,
use extraDashboards instead\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{
  system-overview-v5 = {
    folder = "maintenance";
    path = "/nix/store/34cxgwl28fa2khgys78adxgd81jwpgdy-dashboards/system-overview-v5.json";
  };
}
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dashboards\.\<name>\.editable



Allow editing this dashboard in the Grafana UI\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dashboards\.\<name>\.folder



Grafana folder to place this dashboard in\.



*Type:*
string



*Default:*

```nix
"maintenance"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dashboards\.\<name>\.path



Path to the dashboard JSON file\.



*Type:*
absolute path

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dashboards\.\<name>\.updateInterval



How often Grafana checks for file changes (seconds)\.



*Type:*
signed integer



*Default:*

```nix
10
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.dataDir



Root directory for Grafana data, logs, plugins, and dashboards\.



*Type:*
absolute path



*Default:*

```nix
"/var/lib/grafana"
```



*Example:*

```nix
"/data/grafana"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.domain



Domain name for nginx reverse proxy\. Null disables the proxy\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"grafana.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.externalUrl



URL that links, redirects and notifications point to when no domain is set\. Null keeps the previous fallback\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"http://10.0.0.10:3101/"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.extraDashboards



Names of additional dashboards to provision on this host\.
Each name must match a JSON file in the module’s own dashboards/
directory (e\.g\. “zfs-monitoring” loads dashboards/zfs-monitoring\.json)\.

All extra dashboards are placed in the “maintenance” folder and are
editable by default\.

Example — enable the ZFS dashboard on a host that has ZFS:

services\.observability-grafana\.extraDashboards = \[ “zfs-monitoring” ];

Example — enable multiple extra dashboards:

services\.observability-grafana\.extraDashboards = \[
“zfs-monitoring”
“docker”
“nginx”
];



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "zfs-monitoring"
  "docker"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.extraUsers



Extra users to add to the groups



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.gid



Pinned gid for the grafana group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.group



System group to run Grafana as\.



*Type:*
string



*Default:*

```nix
"grafana"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.listenAddress



IP address to bind to\. Use 0\.0\.0\.0 for all interfaces\.



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.openFirewall



Open firewall ports automatically\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.port



Port for Grafana to listen on\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
3101
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.prometheusUrl



Prometheus URL written into the dashboards’ prometheus_url variable (used by the Open in Prometheus links)\. Must be reachable from the browser\.



*Type:*
string



*Default:*

```nix
"http://localhost:9090"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources



Datasources to auto-provision via Grafana’s file-based provisioning\.
Intended to be set by a stack module wiring this Grafana instance to
sibling services (Prometheus, Loki), not typically set by hand on a host\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    isDefault = true;
    name = "Prometheus";
    type = "prometheus";
    url = "http://127.0.0.1:9090";
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.access



proxy (Grafana backend proxies requests) or direct\.



*Type:*
string



*Default:*

```nix
"proxy"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.editable



This option has no description\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.isDefault



This option has no description\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.jsonData



Extra jsonData fields passed to the datasource plugin\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.name



Datasource name shown in the Grafana UI\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.type



Grafana datasource plugin id (e\.g\. prometheus, loki)\. Plugin
ids are lowercase; the value is lowercased before provisioning\.



*Type:*
string



*Example:*

```nix
"prometheus"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.uid



Stable datasource uid (lets dashboards reference it by id)\. Null lets Grafana generate one\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.provisioning\.datasources\.\*\.url



Datasource URL, e\.g\. http://127\.0\.0\.1:9090\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.secretKeyFile



Path to a file containing Grafana’s ` secret_key `, used to encrypt
secrets stored in the database\. Passed to Grafana via
GF_SECURITY_SECRET_KEY__FILE\. If null, Grafana falls back to its
well-known built-in default key, which is insecure\.

WARNING: changing the key on an existing instance makes secrets
already stored in the database unreadable\. Back up grafana\.db first\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"/run/secrets/GRAFANA_SECRET_KEY"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.secretsFile



Path to the sops-encrypted grafana secrets file\.
Required when the service is enabled; supplied by the consumer (the encrypted file is not part of this repository)\.
Override per-host if needed\.



*Type:*
absolute path

*Declared by:*
 - [\<nixpkgs/sops/grafana\.nix, via option flake\.nixosModules\.nsops--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//sops/grafana.nix, via option flake.nixosModules.nsops--observability-grafana)



## services\.observability-grafana\.timersRegex



Regular expression of systemd timer names shown in the system-overview dashboard’s “Time since each timer last fired” panel (written into the dashboard’s timers_regex variable)\.



*Type:*
string



*Default:*

```nix
"nixos-upgrade.timer|nix-gc.timer"
```



*Example:*

```nix
"nixos-upgrade.timer|backup.timer"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.uid



Pinned uid for the grafana user (null = allocate dynamically)\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-grafana\.user



System user to run Grafana as\.



*Type:*
string



*Default:*

```nix
"grafana"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/grafana/default\.nix, via option flake\.nixosModules\.servc--observability-grafana>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/grafana/default.nix, via option flake.nixosModules.servc--observability-grafana)



## services\.observability-host-exporters\.nodeExporter\.enable



Whether to enable Prometheus node exporter\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.nodeExporter\.listenAddress



Address to bind\.



*Type:*
string



*Default:*

```nix
"localhost"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.nodeExporter\.port



Port of the node exporter\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9100
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.nodeExporter\.textfileDir



Textfile collector directory (the maintenance exporter writes here)\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"/var/lib/node_exporter"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.smartctl\.enable



Whether to enable smartctl (SMART) exporter\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.smartctl\.devices



Disk devices to monitor (empty means scan)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "/dev/sda"
  "/dev/nvme0n1"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.smartctl\.listenAddress



Address to bind\.



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.smartctl\.port



Port of the smartctl exporter\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9633
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-host-exporters\.user



User the node exporter runs as\. Created here if no other module defines it\.



*Type:*
string



*Default:*

```nix
"prometheus"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/host-exporters/default\.nix, via option flake\.nixosModules\.systm--observability-host-exporters>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/host-exporters/default.nix, via option flake.nixosModules.systm--observability-host-exporters)



## services\.observability-loki\.enable

Whether to enable Loki log aggregation system\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.enableSSL



Enable HTTPS with Let’s Encrypt (requires domain)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.package



The Loki package to use



*Type:*
package



*Default:*

```nix
pkgs.grafana-loki
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.dataDir



Directory for Loki data storage



*Type:*
absolute path



*Default:*

```nix
"/var/lib/loki"
```



*Example:*

```nix
"/data/loki"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.domain



Domain name for nginx reverse proxy (optional)



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"loki.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.extraUsers



Extra users to add to the groups



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.gid



Pinned gid for the loki group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.group



Group to run Loki as



*Type:*
string



*Default:*

```nix
"loki"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.grpcPort



gRPC port for Loki internal communication\. Only relevant for multi-instance deployments\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9096
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.listenAddress



IP address to bind to (use 0\.0\.0\.0 for all interfaces)



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.openFirewall



Open firewall ports



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.openGrpcFirewall



Open the gRPC port in the firewall\. Only needed for multi-instance Loki deployments\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.port



Port for Loki to listen on



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
3100
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.retention



How long to retain log data (in hours)



*Type:*
string



*Default:*

```nix
"744h"
```



*Example:*

```nix
"2160h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.retentionStreams



Per-stream retention overrides (rendered into limits_config\.retention_stream)\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.retentionStreams\.\*\.period



This option has no description\.



*Type:*
string



*Example:*

```nix
"17520h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.retentionStreams\.\*\.priority



This option has no description\.



*Type:*
signed integer



*Default:*

```nix
1
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.retentionStreams\.\*\.selector



This option has no description\.



*Type:*
string



*Example:*

```nix
"{job=\"audit\"}"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.ruler\.enable



Whether to enable Loki ruler (LogQL alert rules evaluated inside Loki)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.ruler\.alertmanagerUrl



Alertmanager that receives the ruler’s alerts\. Required when the ruler is enabled\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"http://127.0.0.1:9093"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.ruler\.groups



Rule groups (name, interval, rules) written to the ruler’s local rule directory\.



*Type:*
list of (attribute set)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.uid



Pinned uid for the loki user (null = allocate dynamically)\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-loki\.user



User to run Loki as



*Type:*
string



*Default:*

```nix
"loki"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/loki/default\.nix, via option flake\.nixosModules\.servc--observability-loki>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/loki/default.nix, via option flake.nixosModules.servc--observability-loki)



## services\.observability-maintenance-log\.enable



Whether to enable maintenance task logging helper\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/maintenance-log/default\.nix, via option flake\.nixosModules\.systm--observability-maintenance-log>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/maintenance-log/default.nix, via option flake.nixosModules.systm--observability-maintenance-log)



## services\.observability-maintenance-log\.logPath



Path of the maintenance log (JSON lines)\. Must NOT end in \.log or the /var/log/\*\.log pipeline would ingest it twice\.



*Type:*
string



*Default:*

```nix
"/var/log/maintenance.jsonl"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/maintenance-log/default\.nix, via option flake\.nixosModules\.systm--observability-maintenance-log>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/maintenance-log/default.nix, via option flake.nixosModules.systm--observability-maintenance-log)



## services\.observability-maintenance-log\.lokiJob



Value of the Loki ` job ` label for this log\. Consumers that ship the file must label it with this\. The bundled system-overview dashboard (panels 431 and 432) queries the default value\.



*Type:*
string



*Default:*

```nix
"maintenance-log"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/maintenance-log/default\.nix, via option flake\.nixosModules\.systm--observability-maintenance-log>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/maintenance-log/default.nix, via option flake.nixosModules.systm--observability-maintenance-log)



## services\.observability-maintenance-log\.textfileDir



node_exporter textfile directory; when set, completion metrics are written there every 5 minutes\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"/var/lib/node_exporter"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/maintenance-log/default\.nix, via option flake\.nixosModules\.systm--observability-maintenance-log>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/maintenance-log/default.nix, via option flake.nixosModules.systm--observability-maintenance-log)



## services\.observability-ntfy\.enable



Whether to enable ntfy push notification server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.enableSSL



Enable HTTPS with Let’s Encrypt (requires domain)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.enableWebUI



Enable the ntfy web interface



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.package



The ntfy package to use



*Type:*
package



*Default:*

```nix
pkgs.ntfy-sh
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.attachments\.enable



Enable file attachment support



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.attachments\.expiryDuration



How long attachments are kept before being deleted



*Type:*
string



*Default:*

```nix
"3h"
```



*Example:*

```nix
"24h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.attachments\.sizeLimit



Maximum size per attachment file



*Type:*
string



*Default:*

```nix
"15M"
```



*Example:*

```nix
"50M"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.attachments\.totalSizeLimit



Maximum total size of all attachments combined



*Type:*
string



*Default:*

```nix
"5G"
```



*Example:*

```nix
"10G"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.enable



Whether to enable ntfy authentication and access control\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.defaultAccess



Default access policy for unauthenticated users\.
“deny-all” requires authentication for all operations\.
“read-write” allows anonymous publish and subscribe\.



*Type:*
one of “deny-all”, “read-write”, “read-only”, “write-only”



*Default:*

```nix
"deny-all"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.environmentFile



KEY=VALUE file holding the passwords named by users\.\*\.passwordEnvVar (read by systemd as root)\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users



Users and access rules created at start (idempotent)\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.name



ntfy user name\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.passwordEnvVar



Name of the variable in auth\.environmentFile that holds this user’s password\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.role



ntfy role\.



*Type:*
one of “user”, “admin”



*Default:*

```nix
"user"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.topics



Per-topic access for this user\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.topics\.\*\.access



This option has no description\.



*Type:*
one of “read-write”, “read-only”, “write-only”, “deny-all”

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.auth\.users\.\*\.topics\.\*\.topic



This option has no description\.



*Type:*
string

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.cacheDuration



How long published messages are buffered in the cache



*Type:*
string



*Default:*

```nix
"12h"
```



*Example:*

```nix
"24h"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.cacheFile



Path to the SQLite cache database\. Empty string uses the in-memory
cache (messages are lost on restart)\. Set to a path under dataDir
to persist messages across restarts\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/var/lib/ntfy/cache.db"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.dataDir



Directory for ntfy data storage (cache database, attachments)



*Type:*
absolute path



*Default:*

```nix
"/var/lib/ntfy"
```



*Example:*

```nix
"/data/ntfy"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.domain



Domain name for nginx reverse proxy (optional)



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"ntfy.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.externalUrl



URL that links, redirects and notifications point to when no domain is set\. Null keeps the previous fallback\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"http://10.0.0.10:2586"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.extraUsers



Extra users to add to the ntfy group



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.firebaseKeyFile



Path to a Firebase service account JSON key file\. When set, ntfy
will relay published messages to Firebase Cloud Messaging so that
the official Android/iOS apps can receive push notifications even
when the ntfy app is not running\.
Manage the file with sops-nix or agenix to keep it out of the store\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.gid



Pinned gid for the ntfy group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.group



Group to run ntfy as



*Type:*
string



*Default:*

```nix
"ntfy"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.listenAddress



IP address to bind to (use 0\.0\.0\.0 for all interfaces)



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.openFirewall



Open firewall ports



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.port



Port for ntfy to listen on



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
2586
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.rateLimit\.globalTopicLimit



Total number of topics the server will allow



*Type:*
signed integer



*Default:*

```nix
15000
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.rateLimit\.subscriberRateLimit



Enable rate limiting per subscriber IP



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.smtp\.enable



Whether to enable SMTP server for email-to-ntfy bridge\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.smtp\.addrPrefix



Optional prefix for the SMTP address to disambiguate from other
addresses on the same domain (e\.g\. “ntfy-” → ntfy-mytopic@example\.com)\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"ntfy-"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.smtp\.domain



SMTP domain — must match the MX record for email-to-ntfy



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"ntfy.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.smtp\.listenAddress



Address and port for the SMTP listener



*Type:*
string



*Default:*

```nix
":2525"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.uid



Pinned uid for the ntfy user (null = allocate dynamically)\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.upstreamBaseUrl



Relay poll requests through this server so the official ntfy mobile
apps get instant push notifications from a self-hosted instance\.
Only a message id is sent upstream, never the message content\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"https://ntfy.sh"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-ntfy\.user



User to run ntfy as



*Type:*
string



*Default:*

```nix
"ntfy"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/ntfy/default\.nix, via option flake\.nixosModules\.servc--observability-ntfy>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/ntfy/default.nix, via option flake.nixosModules.servc--observability-ntfy)



## services\.observability-prometheus\.enable



Whether to enable Prometheus monitoring system\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.enableNodeExporter



Enable Prometheus Node Exporter for system metrics



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.enableSSL



Enable HTTPS with Let’s Encrypt (requires domain)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.package



The Prometheus package to use



*Type:*
package



*Default:*

```nix
pkgs.prometheus
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.alertmanagerTargets



Alertmanager host:port targets\. Empty disables alert delivery\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "127.0.0.1:9093"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.blackboxPort



Port of the blackbox exporter\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9115
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.dataDir



Directory for Prometheus time-series data



*Type:*
absolute path



*Default:*

```nix
"/var/lib/prometheus2"
```



*Example:*

```nix
"/data/prometheus"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.domain



Domain name for nginx reverse proxy (optional)



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"prometheus.example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.evaluationInterval



Global rule evaluation interval\.



*Type:*
string



*Default:*

```nix
"15s"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.externalUrl



URL that links, redirects and notifications point to when no domain is set\. Null keeps the previous fallback\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"http://10.0.0.10:9090/"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.extraScrapeConfigs



Additional raw Prometheus scrape_config entries, merged in verbatim
after the base and maintenance scrape configs\. Intended to be set by
a stack module wiring this Prometheus instance to sibling services it
should observe, not typically set by hand on a host\.



*Type:*
list of (attribute set)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    job_name = "ntfy";
    static_configs = [
      {
        targets = [
          "127.0.0.1:2586"
        ];
      }
    ];
  }
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.extraUsers



Extra users to add to the groups



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.gid



Pinned gid for the prometheus group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.listenAddress



IP address for Prometheus to bind to (use 0\.0\.0\.0 for all interfaces)



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.enable



Whether to enable maintenance observability exporters and alerts\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.alerts\.features\.containers



Load ContainerRestartLoop/ContainerHighMemory\. Requires cAdvisor-style container_\* metrics\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.alerts\.features\.postgres



Load PostgresReplicationLag\. Requires a postgres exporter (pg_replication_lag_seconds)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.alerts\.features\.traefik



Load HighHTTPErrorRate\. Requires a scrape job exposing traefik_service_requests_total\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.alerts\.features\.zfsMembers



Load the ZFS member and scrub alerts (ZpoolDeviceErrors, ZpoolDataErrors, ZpoolScrubOverdue, ZpoolScrubErrors, ZpoolMemberMissing, ZpoolMemberReonlined)\. Requires textfile metrics that node_exporter does not produce; see docs/operations/zfs-metrics\.md\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.expectedMounts



Mount points that must exist; ExpectedMountMissing fires when one is absent\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "/data"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.backup\.enable



Enable custom backup status exporter



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.backup\.jobName



Value of the job_name label on backup metrics (used in alert text)\.



*Type:*
string



*Default:*

```nix
"backup"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.backup\.sizeFile



File containing last backup size in bytes



*Type:*
string



*Default:*

```nix
"/var/backups/last_backup_size"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.backup\.timestampFile



File containing last backup timestamp



*Type:*
string



*Default:*

```nix
"/var/backups/last_backup_timestamp"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.enable



Enable blackbox exporter for network probing



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.dnsQueryName



Name resolved by the DNS probe\.



*Type:*
string



*Default:*

```nix
"example.com"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.dnsTargets



DNS servers to probe by resolving dnsQueryName\. Enables DNSResolutionFailure\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "1.1.1.1"
  "192.168.1.1"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.httpInsecureTargets



HTTP targets whose TLS certificate is not verified (internal CA, self-signed)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.httpTargets



HTTP targets to monitor



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "https://example.com"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.icmpTargets



ICMP targets to ping\. Filled by the stack with the gateway and probes\.hosts\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.sslTargets



SSL certificate targets to monitor



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "https://example.com"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.blackbox\.tcpTargets



host:port pairs probed with a TCP connect\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "127.0.0.1:8188"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.smartctl\.enable



Enable SMARTCTL exporter for disk health



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.smartctl\.devices



Disk devices to monitor



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "/dev/sda"
  "/dev/nvme0n1"
]
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.maintenance\.exporters\.systemd



Enable the separate systemd exporter (port 9558)\. The node exporter’s own systemd collector already provides the node_systemd_\* series that the alerts and dashboards use\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.openFirewall



Open firewall ports



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.port

Port for Prometheus to listen on



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9090
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.retention



How long to retain metrics data



*Type:*
string



*Default:*

```nix
"15d"
```



*Example:*

```nix
"30d"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.retentionSize



Cap on TSDB size (–storage\.tsdb\.retention\.size)\. Null means no size cap\. Useful on laptops\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"8GB"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.runbookBaseUrl



Base URL that alert ` runbook ` annotations link to\. The alert name and ` .md ` are appended\.



*Type:*
string



*Default:*

```nix
"https://github.com/Temhr/observability/blob/main/docs/runbooks"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.scrapeInterval



Global scrape interval\.



*Type:*
string



*Default:*

```nix
"15s"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.slowScrapeInterval



Scrape interval for slow-changing jobs (smartctl, blackbox probes)\.



*Type:*
string



*Default:*

```nix
"60s"
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.smartctlPort



Port of the smartctl exporter\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9633
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.systemdExporterPort



Port of the systemd exporter\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9558
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)



## services\.observability-prometheus\.uid



Pinned uid for the prometheus user (null = allocate dynamically)\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [\<nixpkgs/modules/nixos/prometheus/default\.nix, via option flake\.nixosModules\.servc--observability-prometheus>](https://github.com/NixOS/nixpkgs/blob//modules/nixos/prometheus/default.nix, via option flake.nixosModules.servc--observability-prometheus)


