---
weight: 200
title: "USDT Payments"
description: ""
icon: "article"
draft: false
toc: true
---

USDT Payments covers the payment flow from intent creation to settlement. The Acquirer creates a payment intent, t-0 obtains one-time deposit instructions from the Issuer, and the customer pays USDT on-chain from their own wallet by scanning a QR or opening a deeplink.

The QR is only the transport for a chain-native payment URI. The product is USDT acceptance: t-0 verifies the payment, authorizes the sale, and coordinates settlement to the Acquirer in the mode fixed at onboarding.

- [How It Works](how-it-works/) — roles, payment flow, intent states, protocol rules, and links to the generated API reference.
- [Fiat Settlement](fiat-settlement/) — the LP path for Acquirers settled in local fiat over bank rails.
