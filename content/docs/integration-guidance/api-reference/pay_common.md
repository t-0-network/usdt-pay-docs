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


<a name="tzero-v1-pay-Decimal"></a>

### Decimal
Fixed-point monetary amount: unscaled * 10^exponent, so 123.45 is
unscaled=12345, exponent=-2.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| unscaled | [int64](../scalar/#int64) |  | no validation: sign and magnitude are constrained per field by the predicate on the enclosing amount. |
| exponent | [int32](../scalar/#int32) |  |  |







<a name="tzero-v1-pay-DepositOption"></a>

### DepositOption
One selectable deposit option for an intent: the chain, the one-time address
reserved on it, and the chain-native payment URI the POS carries to the customer
(as a QR image, a wallet deep link, or any other carrier) without modification.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| chain | [Blockchain](#tzero-v1-pay-Blockchain) |  | Chain this deposit option pays on. |
| deposit_address | [string](../scalar/#string) |  | One-time deposit address reserved for this intent on `chain`. |
| payment_uri | [string](../scalar/#string) |  | Chain-native payment URI (EIP-681 on EVM chains); produced only by the Issuer and carried to the customer unchanged. |
| token_contract | [string](../scalar/#string) |  | USDt token contract on `chain` the deposit must be made in. |







<a name="tzero-v1-pay-OnChainSettlementDetails"></a>

### OnChainSettlementDetails
One on-chain USDt settlement transfer, as reported by the Issuer on
SettlementSent and relayed to the Acquirer on SettlementCompleted.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| on_chain_tx_hash | [string](../scalar/#string) |  | Hash of the settlement transaction. |
| chain | [Blockchain](#tzero-v1-pay-Blockchain) |  | Chain the settlement moved over. |
| destination_address | [string](../scalar/#string) |  | Registered settlement wallet on `chain` — the Acquirer's (USDt mode) or the LP's (fiat mode). |







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
On-chain network a USDt transfer moves over. Live at launch: ETH and BSC.
TRON already carries a value but is not accepted until it goes live in a
later phase; Arbitrum, Polygon and Avalanche are added as they go live.

| Name | Number | Description |
| ---- | ------ | ----------- |
| BLOCKCHAIN_UNSPECIFIED | 0 |  |
| BLOCKCHAIN_TRON | 10 |  |
| BLOCKCHAIN_ETH | 20 |  |
| BLOCKCHAIN_BSC | 30 |  |



<a name="tzero-v1-pay-FundsDisposition"></a>

### FundsDisposition
Where a deposit's funds end up when the payment will not settle. Final when
reported: whether a retained deposit is later released is decided out of band
and is not part of this contract.

| Name | Number | Description |
| ---- | ------ | ----------- |
| FUNDS_DISPOSITION_UNSPECIFIED | 0 |  |
| FUNDS_DISPOSITION_RETURNED_TO_SENDER | 10 | The Issuer returns the deposit to the customer's sender_address. |
| FUNDS_DISPOSITION_RETAINED_BY_ISSUER | 20 | The Issuer keeps the deposit; the customer resolves it with the Issuer out of band. |


 <!-- end enums -->


