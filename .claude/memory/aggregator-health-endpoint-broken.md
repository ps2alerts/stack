---
name: aggregator-health-endpoint-broken
description: The aggregator's /health returns 500 because its HealthModule never imports HttpModule; compose checks /metrics instead until that is fixed
metadata:
  type: project
  volatility: normal
  lastVerified: 2026-09-15
---

The aggregator exposes `/health` via `@nestjs/terminus` with an API ping, a Redis ping and a
RabbitMQ ping, which would be the ideal Docker healthcheck. It returns 500 in production:
`It seems like "HttpService" is not available in the current context` because the
HealthModule does not import `HttpModule`. Until that is fixed in the aggregator repo and a
new image is published, the compose healthcheck hits `/metrics`, which only proves the
process answers. Switch it back to `/health` once the fix ships.

Related: [[rabbit-dead-while-container-up]].
