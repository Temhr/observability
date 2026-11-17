<h3>6.1 Expected vs. unexpected differences</h3>
<figure class="table">
  <table>
    <thead>
      <tr>
        <th>Where</th>
        <th>Expected?</th>
        <th>Meaning</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>prometheus-rendered.json</code>, <code>runbook</code> annotation URLs</td>
        <td><strong>Yes — the only intended content change</strong> (S7)</td>
        <td>Every rule's <code>annotations.runbook</code> points at the new repo.</td>
      </tr>
      <tr>
        <td><code>units.json</code>: <code>/nix/store/&lt;hash&gt;-…</code> prefixes</td>
        <td>Yes, <strong>hashes only</strong></td>
        <td>Source tree changed. Compare with hashes normalised: <code>sed -E 's#/nix/store/[a-z0-9]{32}-#/nix/store/#g'</code>.</td>
      </tr>
      <tr>
        <td><code>units.json</code>: a <code>…-source/modules/nixos/observability/grafana/dashboards</code> path</td>
        <td>Yes (hash part only)</td>
        <td>Same relative path thanks to D1.</td>
      </tr>
      <tr>
        <td><code>alertmanager.json</code>, <code>loki-ruler.json</code>, <code>datasources.json</code>, <code>alloy-extra.json</code></td>
        <td><strong>No</strong></td>
        <td>Any difference is a regression (typically a lost seam).</td>
      </tr>
      <tr>
        <td><code>firewall-*.json</code>, <code>users.json</code> (UIDs 740–744 etc.)</td>
        <td><strong>No</strong></td>
        <td>State-compat break.</td>
      </tr>
      <tr>
        <td>Any <code>ExecStart*</code>/<code>preStart</code> store path whose <strong>basename</strong> is <code>loki.json</code>, <code>loki-rules.json</code>, or other <code>builtins.toFile</code> outputs</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </tbody>
  </table>
</figure>
