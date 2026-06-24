---
weight: 332
title: "Issuer"
description: ""
icon: "article"
date: "2025-06-16T12:09:09+02:00"
lastmod: "2025-06-16T12:09:09+02:00"
draft: false
toc: true
---

<a name="tzero-v1-pay-IssuerCallbackService"></a>

## IssuerCallbackService
Issuer-implemented endpoint t-0 calls to reserve deposit addresses and obtain
the renderable QR payloads for an intent.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| CreatePaymentInstructions | [CreatePaymentInstructionsRequest](#tzero-v1-pay-CreatePaymentInstructionsRequest) | [CreatePaymentInstructionsResponse](#tzero-v1-pay-CreatePaymentInstructionsResponse) | Reserves one deposit address per supported chain and returns the renderable QR payloads. |


<a name="tzero-v1-pay-IssuerService"></a>

## IssuerService
t-0 endpoints the Issuer calls to report on-chain recognition, settlement,
and reservation expiry.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PaymentReceived | [PaymentReceivedRequest](#tzero-v1-pay-PaymentReceivedRequest) | [PaymentReceivedResponse](#tzero-v1-pay-PaymentReceivedResponse) | Reports the customer's payment seen on-chain and KYT-cleared; the Issuer now owns on-chain risk. |
| SettlementSent | [SettlementSentRequest](#tzero-v1-pay-SettlementSentRequest) | [SettlementSentResponse](#tzero-v1-pay-SettlementSentResponse) | Reports a USDt settlement sent on-chain to the registered destination, for t-0 to verify. |
| PaymentExpired | [IssuerPaymentExpiredRequest](#tzero-v1-pay-IssuerPaymentExpiredRequest) | [IssuerPaymentExpiredResponse](#tzero-v1-pay-IssuerPaymentExpiredResponse) | Confirms the reservation closed with no valid payment and the deposit addresses are released. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-CreatePaymentInstructionsRequest"></a>

### CreatePaymentInstructionsRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent the deposit addresses are reserved for. |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's stable id for the Acquirer; the Issuer resolves its settlement wallet from it. |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Amount the reserved addresses should accept. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Absolute moment t-0 requires the reservation held until, on t-0's clock (t-0 currently sets a 60–120 second window). |







<a name="tzero-v1-pay-CreatePaymentInstructionsResponse"></a>

### CreatePaymentInstructionsResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [CreatePaymentInstructionsResponse.Success](#tzero-v1-pay-CreatePaymentInstructionsResponse-Success) |  |  |
| failure | [CreatePaymentInstructionsResponse.Failure](#tzero-v1-pay-CreatePaymentInstructionsResponse-Failure) |  |  |







<a name="tzero-v1-pay-CreatePaymentInstructionsResponse-Failure"></a>

### CreatePaymentInstructionsResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [CreatePaymentInstructionsResponse.Failure.Reason](#tzero-v1-pay-CreatePaymentInstructionsResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-CreatePaymentInstructionsResponse-Success"></a>

### CreatePaymentInstructionsResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| qr_options | [QrOption](../pay_types/#tzero-v1-pay-QrOption) | repeated | One option per chain the Issuer supports for this intent. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Absolute expiry of the reservation. |







<a name="tzero-v1-pay-IssuerPaymentExpiredRequest"></a>

### IssuerPaymentExpiredRequest
`PaymentExpired` is also a method on AcquirerCallbackService in this flat
package, so the request/response carry a role prefix to avoid a colliding
`PaymentExpiredRequest`. Interim name: buf STANDARD RPC_REQUEST_STANDARD_NAME
accepts only bare `PaymentExpiredRequest` or the full
`IssuerServicePaymentExpiredRequest`, so this short form needs a lint
ignore at graduation (or rename the method).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent whose reservation expired. |
| expired_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer released the deposit addresses. |







<a name="tzero-v1-pay-IssuerPaymentExpiredResponse"></a>

### IssuerPaymentExpiredResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [IssuerPaymentExpiredResponse.Accepted](#tzero-v1-pay-IssuerPaymentExpiredResponse-Accepted) |  |  |
| rejected | [IssuerPaymentExpiredResponse.Rejected](#tzero-v1-pay-IssuerPaymentExpiredResponse-Rejected) |  |  |







<a name="tzero-v1-pay-IssuerPaymentExpiredResponse-Accepted"></a>

### IssuerPaymentExpiredResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-IssuerPaymentExpiredResponse-Rejected"></a>

### IssuerPaymentExpiredResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [IssuerPaymentExpiredResponse.Rejected.Reason](#tzero-v1-pay-IssuerPaymentExpiredResponse-Rejected-Reason) |  |  |







<a name="tzero-v1-pay-PaymentReceivedRequest"></a>

### PaymentReceivedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent the on-chain payment satisfies. |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Amount credited; must equal the intent's stored amount_usdt exactly. |
| usdt_on_chain | [UsdtOnChainPayment](../pay_types/#tzero-v1-pay-UsdtOnChainPayment) |  |  |
| received_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer treated the payment as final. |







<a name="tzero-v1-pay-PaymentReceivedResponse"></a>

### PaymentReceivedResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [PaymentReceivedResponse.Accepted](#tzero-v1-pay-PaymentReceivedResponse-Accepted) |  |  |
| rejected | [PaymentReceivedResponse.Rejected](#tzero-v1-pay-PaymentReceivedResponse-Rejected) |  |  |







<a name="tzero-v1-pay-PaymentReceivedResponse-Accepted"></a>

### PaymentReceivedResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-PaymentReceivedResponse-Rejected"></a>

### PaymentReceivedResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [PaymentReceivedResponse.Rejected.Reason](#tzero-v1-pay-PaymentReceivedResponse-Rejected-Reason) |  |  |







<a name="tzero-v1-pay-SettlementSentRequest"></a>

### SettlementSentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| settlement_ref | [string](../scalar/#string) |  | Issuer's id for this USDt settlement; idempotency key, unique per Issuer. |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Total USDt settled across the covered intents. |
| settlement | [OnChainSettlementDetails](../pay_types/#tzero-v1-pay-OnChainSettlementDetails) |  | On-chain transaction, chain, and registered destination wallet for this settlement. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents this settlement clears; per-intent amounts are resolved by t-0 from the accepted intents. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer broadcast the settlement transaction. |







<a name="tzero-v1-pay-SettlementSentResponse"></a>

### SettlementSentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [SettlementSentResponse.Accepted](#tzero-v1-pay-SettlementSentResponse-Accepted) |  |  |
| rejected | [SettlementSentResponse.Rejected](#tzero-v1-pay-SettlementSentResponse-Rejected) |  |  |







<a name="tzero-v1-pay-SettlementSentResponse-Accepted"></a>

### SettlementSentResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-SettlementSentResponse-Rejected"></a>

### SettlementSentResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [SettlementSentResponse.Rejected.Reason](#tzero-v1-pay-SettlementSentResponse-Rejected-Reason) |  |  |
| failing_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents that failed verification within the batch. |






 <!-- end messages -->


<a name="tzero-v1-pay-CreatePaymentInstructionsResponse-Failure-Reason"></a>

### CreatePaymentInstructionsResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ISSUER_UNAVAILABLE | 10 | The Issuer is unavailable to allocate. |
| REASON_ADDRESS_POOL_EMPTY | 20 | No free one-time deposit addresses. |
| REASON_AMOUNT_OUT_OF_RANGE | 40 | The amount falls outside the acceptable range. |



<a name="tzero-v1-pay-IssuerPaymentExpiredResponse-Rejected-Reason"></a>

### IssuerPaymentExpiredResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_UNKNOWN_INTENT | 10 | payment_intent_id is one t-0 never opened. |



<a name="tzero-v1-pay-PaymentReceivedResponse-Rejected-Reason"></a>

### PaymentReceivedResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_INTENT_EXPIRED | 10 | Received after expires_at on t-0's clock. |
| REASON_UNKNOWN_INTENT | 20 | No such intent exists. |
| REASON_AMOUNT_MISMATCH | 30 | amount_usdt is not exactly the intent's stored amount. |



<a name="tzero-v1-pay-SettlementSentResponse-Rejected-Reason"></a>

### SettlementSentResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ON_CHAIN_UNCONFIRMED | 10 | The on-chain transaction is not yet confirmed. |
| REASON_AMOUNT_MISMATCH | 20 | The confirmed amount does not equal amount_usdt or the covered intents' sum. |
| REASON_WRONG_DESTINATION | 30 | destination_address (or its chain) is not the expected registered (chain, address) pair for the mode. |
| REASON_INTENT_NOT_SETTLEABLE | 40 | A listed intent is not in a settleable state (USDt mode: SETTLEMENT_PENDING; fiat mode: authorized). |


 <!-- end enums -->


