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

- **Acquirer** — call `AcquirerService` (get a quote, create a payment intent, confirm fiat receipt); implement `AcquirerCallbackService` (authorization and settlement events).
- **Issuer** — call `IssuerService` (payment received, settlement sent, expiry); implement `IssuerCallbackService` (create payment instructions).
- **Liquidity Provider** — call `LpService` (publish and withdraw quotes, fiat settlement sent); implement `LpCallbackService` (execute quote).

The service and message definitions are in the [API Reference](api-reference/), generated from `acquirer.proto`, `issuer.proto`, `lp.proto`, and `types.proto`. Generate your client and server stubs from those definitions.

## API endpoints

Sandbox and production endpoints are provided during onboarding.

## Idempotency and reliability

Every state-changing method declares an idempotency level for safe retries and duplicate prevention. See [Idempotency and Reliability](idempotency) for the contract your endpoints must uphold and the reconciliation timers t-0 applies.
