---
weight: 200
title: "QR Payments"
description: ""
icon: "qr_code_2"
draft: false
toc: true
---

The QR payment flow: a customer pays USDT on-chain by scanning a merchant's QR code, and the merchant's Acquirer is settled in USDT or in local fiat.

- [QR Payment API](qr-api/) — the single normative contract: participants, end-to-end flow, payment-intent states, and every endpoint with its fields and decline codes.
- [Fiat Settlement](fiat-settlement/) — the Liquidity Provider path, where the Acquirer is settled in local currency over bank rails.
