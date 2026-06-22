---
weight: 301
title: "Integration Guidance"
description: ""
icon: "article"
draft: false
toc: true
---

You integrate with USDT Pay by implementing the QR payment protocols over the t-0 network. Communication uses the Connect RPC framework, which supports both gRPC and REST/JSON encoding. Every request carries a cryptographic signature for authentication and integrity verification (see [Request Authentication](protocol/authentication)).

Your role determines which services you call and which callbacks you implement:

- **Acquirer** — call `AcquirerService` (get a quote, create a payment intent, confirm fiat receipt); implement `AcquirerCallbackService` (authorization and settlement events).
- **Issuer** — call `IssuerService` (payment received, settlement sent, expiry); implement `IssuerCallbackService` (create payment instructions).
- **Liquidity Provider** — call `LpService` (publish and withdraw quotes, fiat settlement sent); implement `LpCallbackService` (execute quote).

The full service and message definitions live in the [API Reference](api-reference/), generated from `acquirer.proto`, `issuer.proto`, `lp.proto`, and `types.proto`.

## API endpoints

Sandbox and production endpoints are provided during onboarding.

## Idempotency and request safety

Every state-changing method declares an idempotency level for safe retries and duplicate prevention. See [Idempotency](idempotency) for the reliability contract and what your endpoints must guarantee.

## Protocol implementation

Generate client and server stubs from the protocol buffer definitions, then implement the services for your role. All methods are unary request/response.

### gRPC

gRPC uses binary encoding for high-throughput, strongly-typed communication, well suited to high-volume payment processing. Strongly-typed interfaces enforce the API contract and catch integration errors at compile time. Implement retry logic and circuit-breaker patterns for network interruptions.

### REST/JSON

REST/JSON offers broader compatibility and human-readable messages, easier to debug and monitor, and suits systems with existing REST architectures. The Connect RPC framework exposes a REST endpoint for each method; both encodings share the same functionality, with JSON following the protocol buffer JSON mapping so the two stay consistent. Handle HTTP status codes, error responses, and content negotiation in your implementation.
