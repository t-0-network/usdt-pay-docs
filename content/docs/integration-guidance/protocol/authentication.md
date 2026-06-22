---
weight: 371
title: "Request Authentication"
description: ""
icon: "article"
draft: false
toc: true
---

Every request between t-0 and a role (Acquirer, Issuer, or LP) is signed. Signing uses an ECDSA signature over a Keccak-256 hash — the same primitives as Ethereum — giving both authentication and message integrity. Both directions are signed: t-0 signs the requests it sends to a role, and each role signs the requests it sends to t-0.

## Request signing

Each request carries three headers:

- `X-Signature` — the hex-encoded ECDSA signature of the request body with the timestamp appended.
- `X-Public-Key` — the hex-encoded public key for the signing key. Compressed (33 bytes) or uncompressed (65 bytes); compressed is preferred.
- `X-Signature-Timestamp` — the Unix timestamp in milliseconds used during signing.

To sign a request: take the current Unix timestamp in milliseconds as a 64-bit unsigned integer encoded little-endian, append it to the request body, hash the result with Keccak-256, and sign the hash with the sender's ECDSA private key.

## Verification

The receiver reverses the operation: read the timestamp from `X-Signature-Timestamp`, append it to the request body, hash with Keccak-256, and verify the signature against the sender's registered public key.

Reject a request whose timestamp is more than one minute from the current time — this bounds replay. Reject any request whose signature does not verify.
