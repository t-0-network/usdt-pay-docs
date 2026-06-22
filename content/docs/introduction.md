---
weight: 100
title: "Introduction"
description: ""
icon: "article"
draft: false
toc: true
---

USDT Pay is a non-custodial QR payment flow on the t-0 network. A customer scans a merchant's QR code and pays in USDT on-chain from their own wallet; the merchant's Acquirer is settled either in USDT or in its local currency, without holding crypto or running an FX desk.

## Participants

Four parties take part, and each talks only to its neighbour:

- **Acquirer** — owns the merchant relationship and the POS, opens the payment intent, and relays authorization back to the merchant.
- **t-0** — routes messages between parties, owns the payment-intent ledger, maintains the order book of Liquidity Provider quotes, and verifies settlement on-chain.
- **Issuer** — allocates one-time deposit addresses, builds the QR payload, watches the blockchain, screens the customer (KYT), and settles in USDT.
- **Liquidity Provider (LP)** — in fiat mode, receives the Issuer's USDT and pays the Acquirer local fiat over bank rails at a locked rate.

## Settlement modes

The customer always pays USDT on-chain. The settlement mode, fixed per Acquirer at onboarding, changes only how the Acquirer receives value:

- **USDT settlement** — the Issuer settles USDT on-chain straight to the Acquirer's wallet.
- **Fiat settlement** — the Issuer settles USDT to an LP, and the LP delivers local fiat to the Acquirer over bank rails.

## Where to go next

- [QR Payments](/docs/payments/) — the product flow, the normative API contract, and the fiat settlement path.
- [Integration Guidance](/docs/integration-guidance/) — authentication, idempotency, and the API reference generated from the proto.
