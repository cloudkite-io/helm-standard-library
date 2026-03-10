# 1.9.0
* HTTPRoute: Add `gateway` field (`internal`|`external`) to replace verbose `parentRefs` blocks. Defaults to `internal` (traefik-internal-gateway). Explicit `parentRefs` still takes precedence for full customization.
* HTTPRoute: Add `middlewares` list to auto-generate Traefik ExtensionRef filters per rule, replacing repetitive filter blocks in values files.
* HTTPRoute: Add optional `sectionName` field (defaults to `https`) to customize the gateway listener referenced by the route.
* Add `traefikMiddlewares` template to create Traefik Middleware CRDs directly from values (similar to `snippetsFilters` for nginx).

# 0.3.0
* implemented services, ports, readiness probe, volume mounts and resources configuration support at the container level in deployments