---
weight: 337
title: "Shared Types"
description: ""
icon: "article"
date: "2025-06-16T12:09:09+02:00"
lastmod: "2025-06-16T12:09:09+02:00"
draft: false
toc: true
---
 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-OnChainSettlementDetails"></a>

### OnChainSettlementDetails
USDt-on-chain settlement payload, shared by the issuer's SettlementSent and
the acquirer's SettlementCompleted usdt variant.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| on_chain_tx_hash | [string](../scalar/#string) |  | Hash of the settlement transaction. |
| chain | [Blockchain](#tzero-v1-pay-Blockchain) |  | Chain the settlement moved over. |
| destination_address | [string](../scalar/#string) |  | Registered settlement wallet on `chain` — the Acquirer's (USDt mode) or the LP's (fiat mode). |







<a name="tzero-v1-pay-QrOption"></a>

### QrOption
One selectable QR payment option for an intent — the renderable payload is
chain-native and encoded by the POS without modification.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| chain | [Blockchain](#tzero-v1-pay-Blockchain) |  | Chain this deposit option pays on. |
| deposit_address | [string](../scalar/#string) |  | One-time deposit address reserved for this intent on `chain`. |
| renderable_payload | [string](../scalar/#string) |  | Chain-native URI (e.g. ERC-681 on EVM) the POS encodes as a QR image as-is. |







<a name="tzero-v1-pay-UsdtOnChainPayment"></a>

### UsdtOnChainPayment
One on-chain USDt transfer made by the customer. The only payment-method
variant in the MVP.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| chain | [Blockchain](#tzero-v1-pay-Blockchain) |  | Chain the customer's USDt transfer moved over. |
| on_chain_tx_hash | [string](../scalar/#string) |  | Hash of the customer's USDt transfer. |
| sender_address | [string](../scalar/#string) |  | Customer's source wallet address, for receipt and audit. |






 <!-- end messages -->


<a name="tzero-v1-pay-Blockchain"></a>

### Blockchain
On-chain network a USDt leg moves over. Local to the pay contract.
Launch-live: TRON, ETH, BSC. Six more (Polygon, Arbitrum, Optimism, Base,
Avalanche, Solana) are announced as upcoming and added here as they go live.
Wire names are the full chain names; these enum labels are the internal mapping.

| Name | Number | Description |
| ---- | ------ | ----------- |
| BLOCKCHAIN_UNSPECIFIED | 0 |  |
| BLOCKCHAIN_TRON | 10 |  |
| BLOCKCHAIN_ETH | 20 |  |
| BLOCKCHAIN_BSC | 30 |  |


 <!-- end enums -->


