---
weight: 250
title: "Liquidity Provider"
description: "Integration reference for engineers at a Liquidity Provider connecting to t-0."
icon: "article"
draft: false
toc: true
---

You exist in the protocol for fiat-mode Acquirers. You price foreign-exchange quotes, accept executions at the locked rate, and pay the Acquirer over bank rails. The Issuer's USDT reaches your wallet with no protocol message to announce it. The Acquirer's confirmation of your bank transfer stays between the Acquirer and t-0: you receive nothing after t-0 accepts your `§10`. You exchange no direct calls with the Acquirer or the Issuer. See the [usdt-pay-sdk](https://github.com/t-0-network/usdt-pay-sdk) repository for stubs and starters.

A sale is authorized after `§7` and settled after `§12` (fiat mode) or `§13` (USDt mode).

## Before you start

1. Exchange your secp256k1 public key with t-0 at onboarding and receive t-0's.
2. Set the sandbox or production endpoint from the same exchange.
3. Expose a callback URL t-0 can reach.
4. Handle every amount as `Decimal{unscaled, exponent}` with decimal-safe arithmetic.

## What you host and what you call

| Direction | Endpoint | Mode | Key | API reference |
|---|---|---|---|---|
| You call | `§1 PublishQuote` | fiat | `quoteRef` (per quote in the batch) | [PublishQuoteRequest](/docs/integration-guidance/api-reference/pay_lp/#tzero-v1-pay-lp-PublishQuoteRequest) |
| You call | `§10 FiatSettlementSent` | fiat | `bankTransferRef` | [FiatSettlementSentRequest](/docs/integration-guidance/api-reference/pay_lp/#tzero-v1-pay-lp-FiatSettlementSentRequest) |
| You host | `§8 ExecuteQuote` | fiat | `executionId` (dedup key) | [ExecuteQuoteRequest](/docs/integration-guidance/api-reference/pay_lp/#tzero-v1-pay-lp-ExecuteQuoteRequest) |

## Flow from your side

`->>` a call, `-->>` its response, `-)` an on-chain or bank transfer, `Note` something outside your systems or done locally.

### Standing quotes

```mermaid
sequenceDiagram
    participant LP as You (LP)
    participant T0 as t-0

    loop before each quote expires
        LP->>T0: §1 PublishQuote (quotes[])
        T0-->>LP: quoteIds[]
        Note over LP: at most one quote per currency per call
        Note over LP,T0: the batch is atomic. A currency you stop quoting becomes unavailable to your Acquirers at §3
    end
```

### One authorized sale

```mermaid
sequenceDiagram
    participant LP as You (LP)
    participant T0 as t-0
    participant BC as Chain
    participant BANK as Bank

    T0->>LP: §8 ExecuteQuote (executionId, quoteId, acquirerId, localAmount, amountUsdt, fxRate)
    LP-->>T0: Accepted
    Note over LP: firm obligation at fxRate
    Note over LP,BC: the two legs below run in either order
    BC-)LP: Issuer's USDT lands in your wallet
    LP-)BANK: pay localAmount to the Acquirer's account
    LP->>T0: §10 FiatSettlementSent (bankTransferRef, settledExecutionIds[], settlementAmount)
    T0-->>LP: Accepted
    Note over T0: t-0 takes it from here. It sends you nothing further
```

One Issuer transfer may cover executions for several Acquirers. One bank transfer credits one Acquirer and may batch several executions for that Acquirer. A `Rejected` answer on `§8` ends your part in that sale.

## When the sale does not complete

**You reject the execution.** You answer `§8` with `Rejected`. The intent stays authorized and moves to manual handling. You receive nothing further for it.

**The customer does not pay, or the deposit is refused.** No `§8` reaches you. The quote stands for the next sale.

**Your `§10` is rejected.** The bank transfer already happened. Resubmit the same `bankTransferRef` with corrected fields.

## What t-0 checks on your calls

### §1 PublishQuote

t-0 validates the whole batch before it looks up any `quoteRef`.

| Reason | Condition | What to do |
|---|---|---|
| `InvalidArgument` | Duplicate `quoteRef` or duplicate currency in one call, or `fxRate` outside t-0's accepted magnitude | Fix the request and resend |
| `VALIDITY_INVALID` | Any quote's `expiresAt` is too near or too far from now (whole batch declined, no ref consumed) | Adjust the validity window and resend |

Because validation runs first, an unchanged retry can fail `VALIDITY_INVALID` once its remaining validity has dropped below t-0's minimum, even though the quote still stands. A valid resubmission of a known `quoteRef` returns its original `quoteId` and changes nothing in the book. Refreshed terms need a fresh `quoteRef`.

### §8 ExecuteQuote

t-0 records what you answer.

| Your answer | What t-0 does |
|---|---|
| `Accepted` | Records the obligation at the locked rate |
| `Rejected` | Records `details` (the `reason` enum is dropped). The intent stays authorized for manual handling. No retry |
| Lost reply | t-0 redelivers under the same `executionId` until you answer |
| Repeat after a stored result | No-op |

### §10 FiatSettlementSent

t-0 checks in this order. A rejection does not consume the `bankTransferRef`.

| Reason | Condition | What to do |
|---|---|---|
| `EXECUTION_UNKNOWN` | An execution id is unknown, belongs to another LP, or was rejected | Remove it from the set and resubmit |
| `FAILED_PRECONDITION` | A listed execution has no durable result yet | Retry the same request |
| `ACQUIRER_MIXED` | The execution set spans more than one Acquirer | Split into one report per Acquirer |
| `CURRENCY_MISMATCH` | `settlementAmount` currency differs from the locked currency of an execution | Fix the currency and resubmit |
| `AMOUNT_MISMATCH` | `settlementAmount` does not equal the sum of the executions' locked local amounts | Fix the amount and resubmit |
| `EXECUTION_ALREADY_COVERED` | An execution is covered by an accepted settlement | Remove it from the set |
| `BANK_TRANSFER_REF_CONFLICT` | Same `bankTransferRef` accepted with a different currency, amount, or execution set | Use a fresh `bankTransferRef` for the new transfer |

## What you must guarantee (t-0 does not check it)

- t-0 holds no bank account for any Acquirer. Paying the right account is yours alone. Hold the Acquirer's bank account per `acquirerId` from your own onboarding mapping.
- One bank transfer credits one Acquirer.
- Write durably before acknowledging any callback. t-0 redelivers until it gets a success response, with no cap, and can redeliver once more after a success it failed to record.
- Dedup `§8` on `executionId` and answer the same result on a repeat. `Rejected` is a durable business decision.
- Dedup even after you acknowledged. Callbacks can arrive in any order.
- Watch your own wallet for the Issuer's USDT. You receive no `§9` and no notification when the transfer lands.
- The Issuer's USDT may arrive after you paid the Acquirer. You carry that timing risk.
- Refresh quotes before they lapse, or your Acquirers' fiat sales stop at `§3`. A quote must outlive the intent's QR window to be usable at `§4`, so refresh with that margin. Your Acquirers will pass `§3` and fail `§4` near each quote's end if the headroom is too short.
- An older quote stays referenceable by `quoteId` until its own expiry after you publish a newer one. Keep the terms of every quote you published.
- A `§8` can reach you after the quote it references has expired. It binds you at that quote's rate.
- Treat `FAILED_PRECONDITION` on `§10` as "retry the same request."

## Reconcile against t-0

Watch your wallet for the Issuer's USDT and match each transfer against the executions you accepted at `§8`. Match each bank transfer you sent against the `§10` acceptance from t-0. t-0's `§10` acceptance is the record that your fiat obligation for those executions is discharged. You have no view of the Acquirer's `§12` confirmation; if your `§10` is accepted, your part is done.

## Checklist

1. Publish a quote per currency you serve and refresh it before it lapses.
2. Host `§8` over the signed transport.
3. Dedup `§8` on `executionId` and answer the same result on a repeat.
4. Hold the Acquirer bank account per `acquirerId` yourself.
5. Watch your wallet for the Issuer's USDT.
6. Pay one Acquirer per bank transfer with a unique `bankTransferRef`.
7. Send `§10` with the execution set and the exact sum.
8. Retry on `FAILED_PRECONDITION`.
9. Resubmit the same `bankTransferRef` on a rejection with corrected fields.
10. Write durably before acknowledging any callback.
