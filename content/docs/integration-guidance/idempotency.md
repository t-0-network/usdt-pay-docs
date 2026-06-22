---
weight: 302
title: "Idempotency and Reliability"
description: ""
icon: "article"
draft: false
toc: true
---

Connections drop and requests time out. t-0 and the roles deliver every state-changing message at least once, retrying with backoff until the receiver acknowledges, so your endpoint can receive the same request more than once. Idempotency makes those retries safe: a repeat with the same key returns the original result and causes no further side effect.

At-least-once delivery plus idempotent receivers produces exactly-once processing without a coordination protocol. Both t-0 and every role must hold their side of the contract.

## Idempotency keys

Each state-changing call carries a designated key, scoped to the authenticated caller:

| Key | Endpoint(s) | Minted by | Scope |
|-----|-------------|-----------|-------|
| `paymentRef` | `4 CreatePaymentIntent` | Acquirer | per Acquirer |
| `settlementRef` | `9 SettlementSent` | Issuer | per Issuer |
| `quoteRef` | `1 PublishQuote` | LP | per LP |
| `bankTransferRef` | `10 FiatSettlementSent`, `12 SettlementReceived` | LP | per LP (`12` keyed on the pair `lpId` + `bankTransferRef`) |
| `quoteId` | `2 WithdrawQuote` | t-0 | global |
| `executionId` | `8 ExecuteQuote` | t-0 | global |
| `paymentIntentId` | `5`, `6`, `7`, `14`, `15` | t-0 | global |

t-0-minted keys (`paymentIntentId`, `quoteId`, `executionId`, `settlementId`, `fiatSettlementId`) are globally unique by construction. Every `t-0 → role` call is keyed on a t-0-minted id; t-0 never uses one role's id as the key in a message to another role.

## Request categories

Every method declares one of two idempotency levels:

**IDEMPOTENT** — the request changes state (publish a quote, create a payment intent, report a settlement). Deduplicate on the business key in the request body; retrying produces the same outcome as the first call.

**NO_SIDE_EFFECTS** — the request is a read-only lookup. The only one is `3 GetPaymentQuote`, which has no key and always returns the current standing quote. Safe to retry freely.

## Three rules for receivers

### 1. Return the original response for a completed request

When a request arrives with a key you have already processed, return the stored response — the caller needs the outcome, not a "duplicate" error.

The Issuer reports `6 PaymentReceived` for `paymentIntentId` 42, and the connection drops before t-0's acknowledgment lands. The Issuer retries the same call with `paymentIntentId` 42. t-0 returns the same accepted result; the intent is authorized once, and the flow continues. Returning a failure instead would strand the payment.

### 2. Wait for an in-flight request

If you have not finished the original request when a duplicate arrives, wait for it to complete and return the same response to both. Do not reject the duplicate, and do not return an error.

### 3. Never treat a duplicate as an error

A duplicate is a normal retry, not a fault. Returning an error for it breaks the contract and stalls the payment. Use the request's key (such as `paymentRef`) to tell a repeat apart from a genuinely new request.

## Retries, rejections, and replay

A sender that gets no acknowledgment retries with the original key and identical content; the receiver dedupes. A **rejection** is itself an acknowledgment, so the sender stops retrying — but it never consumes the key: to fix the problem the sender resubmits the same key with corrected fields, which t-0 re-evaluates from scratch. **Idempotent replay** — returning the original result with no new side effect — applies only to an accepted call; a rejected or declined call commits nothing to replay.

Inbound asynchronous endpoints (`6`, `9`, `10`, `12`, `14`) acknowledge with `accepted` or `rejected { rejectionCode, ... }`. A genuinely different real-world action — a new on-chain settlement transaction, a second bank transfer — is a new event under a new key, reconciled out of band; it is not a correction of the old key.

## Reliability

- **At-least-once delivery** on the asynchronous endpoints (`6`, `7`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `15`). The sender retries with backoff until the receiver acknowledges.
- **t-0 is the source of truth** for intent state and for on-chain settlement verification. The Acquirer, Issuer, and LP reconcile against t-0, not against each other.
- **Reconciliation timers** — t-0 runs mode-specific escalation timers (thresholds are contractual parameters):
  - *USDT mode* — an intent stuck in `SETTLEMENT_PENDING` past T₁ (its `9` not yet verified) escalates to the Issuer.
  - *Fiat mode, bank-rails leg* — no `10 FiatSettlementSent` within T₂ of authorization escalates to the LP.
  - *Fiat mode, confirmation leg* — no `12 SettlementReceived` within T₃ of `11 SettlementInitiated` escalates to the Acquirer.
  - *Fiat mode, Issuer→LP reimbursement* — the Issuer's `9` to the LP wallet not verified within T₄ escalates to the Issuer.

The Issuer is the responsible party for every unsettled obligation; it is never passed back to the Acquirer.
