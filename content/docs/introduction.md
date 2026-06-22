---
weight: 100
title: "Introduction"
description: ""
icon: "article"
draft: false
toc: true
---

USDT Pay lets Acquirers accept customer USDT payments without taking custody of customer funds. The customer pays on-chain from their own wallet to a one-time deposit address. t-0 verifies the payment and tracks the payment intent through authorization and settlement.

Four roles take part:

- **Acquirer** — owns the merchant relationship, creates the payment intent, and receives settlement.
- **Issuer** — creates payment instructions, allocates one-time deposit addresses, watches the blockchain, and settles USDT.
- **Liquidity Provider (LP)** — in fiat settlement mode, receives USDT from the Issuer and pays local fiat to the Acquirer over bank rails.
- **t-0** — routes messages, owns payment-intent state, maintains the LP standing quotes, and verifies on-chain settlement.

Each Acquirer has one settlement mode, fixed at onboarding. In **USDT settlement**, the Issuer settles USDT on-chain to the Acquirer's wallet. In **fiat settlement**, the Issuer settles USDT to the LP, and the LP settles local fiat to the Acquirer.

Start with [USDT Payments](/docs/payments/) for the payment flow. Use [Integration Guidance](/docs/integration-guidance/) for authentication, idempotency, and the generated API reference.
