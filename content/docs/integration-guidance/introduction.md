---
weight: 301
title: "Integration Guidance"
description: ""
icon: "article"
draft: false
toc: true
---

You integrate with USDT Pay by implementing the protocol over the t-0 network. Communication uses Connect RPC, so every method is available over gRPC and over HTTP/JSON with the same request and response types. Every request is signed (see [Request Authentication](protocol/authentication)).

Your role determines which services you call and which callbacks you implement:

- **Acquirer** — call `AcquirerService` (get a quote, create a payment intent, confirm fiat receipt); implement `AcquirerCallbackService` (authorization, settlement, expiry and failure events). See the [Acquirer integration page](/docs/payments/acquirer/) for the full flow from your side.
- **Issuer** — call `IssuerService` (payment received, settlement sent); implement `IssuerCallbackService` (create payment instructions). See the [Issuer integration page](/docs/payments/issuer/) for the full flow from your side.
- **Liquidity Provider** — call `LpService` (publish quotes, fiat settlement sent); implement `LpCallbackService` (execute quote). See the [LP integration page](/docs/payments/liquidity-provider/) for the full flow from your side.

The service and message definitions are in the [API Reference](api-reference/), generated from `acquirer/acquirer.proto`, `issuer/issuer.proto`, `lp/lp.proto`, and `common.proto` under `proto/tzero/v1/pay/`. Generate your client and server stubs from those definitions.

## API endpoints

| Environment | Base URL | Egress IP |
|---|---|---|
| Sandbox | {{< infra-param "api.domain.sandbox" "https://" >}} | {{< infra-param "egress.ip.sandbox" >}} |
| Production | {{< infra-param "api.domain.production" "https://" >}} | {{< infra-param "egress.ip.production" >}} |

t-0 calls your callback URL from the egress IP. You decide whether to add it to your firewall allowlist. Either way, verify the signature on every request from t-0 (see [Request Authentication](protocol/authentication)).

t-0 uses a separate public key in each environment. You receive both at onboarding.

## Idempotency and reliability

Every state-changing method declares an idempotency level for safe retries and duplicate prevention. See [Idempotency and Reliability](idempotency) for the contract your endpoints must uphold and the reconciliation timers t-0 applies.
