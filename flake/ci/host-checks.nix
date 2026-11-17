{self, ...}: {
  flake.lib.observabilityHostChecks = {
    pkgs,
    name,
    hostConfig,
  }: let
    inherit (self.lib) prometheusRendered;
    toJson = n: value: pkgs.writeText n (builtins.toJSON value);
    tools = [pkgs.prometheus.cli pkgs.prometheus-alertmanager pkgs.remarshal pkgs.gettext];
    rendered = prometheusRendered {
      config = hostConfig;
      lib = pkgs.lib;
    };
  in {
    "prom-config-${name}" = pkgs.runCommand "prom-config-${name}" {nativeBuildInputs = tools;} ''
      remarshal -i ${toJson "prometheus.json" rendered.prometheusConfig} -if json -of yaml -o prometheus.yml
      promtool check config --syntax-only prometheus.yml
      touch $out
    '';
    "prom-rules-${name}" = pkgs.runCommand "prom-rules-${name}" {nativeBuildInputs = tools;} ''
      remarshal -i ${toJson "rules.json" rendered.rules} -if json -of yaml -o rules.yml
      promtool check rules rules.yml
      touch $out
    '';
    "alertmanager-config-${name}" = pkgs.runCommand "alertmanager-config-${name}" {nativeBuildInputs = tools;} ''
      remarshal -i ${toJson "am.json" hostConfig.services.prometheus.alertmanager.configuration} -if json -of yaml -o am.yml
      for v in $(grep -o '\$[A-Z_][A-Z0-9_]*' am.yml | tr -d '$' | sort -u); do export "$v=dummy"; done
      envsubst < am.yml > am.sub.yml
      amtool check-config am.sub.yml
      touch $out
    '';
  };
}
