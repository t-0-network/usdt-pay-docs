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

<a name="tzero-v1-pay-issuer-IssuerCallbackService"></a>

## IssuerCallbackService
Issuer-implemented endpoint t-0 calls to reserve deposit addresses and obtain
the deposit options (chain-native payment URIs) for an intent.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| CreatePaymentInstructions | [CreatePaymentInstructionsRequest](#tzero-v1-pay-issuer-CreatePaymentInstructionsRequest) | [CreatePaymentInstructionsResponse](#tzero-v1-pay-issuer-CreatePaymentInstructionsResponse) | Reserves one deposit address per supported chain and returns the deposit options with their payment URIs. |


<a name="tzero-v1-pay-issuer-IssuerService"></a>

## IssuerService
t-0 endpoints the Issuer calls to report what it did with a customer deposit
and the USDt settlements that clear the intents it covers.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PaymentReceived | [PaymentReceivedRequest](#tzero-v1-pay-issuer-PaymentReceivedRequest) | [PaymentReceivedResponse](#tzero-v1-pay-issuer-PaymentReceivedResponse) | Reports a deposit seen on-chain against an intent and the Issuer's final disposition of it. |
| SettlementSent | [SettlementSentRequest](#tzero-v1-pay-issuer-SettlementSentRequest) | [SettlementSentResponse](#tzero-v1-pay-issuer-SettlementSentResponse) | Reports a USDt settlement sent on-chain to the registered destination, for t-0 to verify. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-issuer-CreatePaymentInstructionsRequest"></a>

### CreatePaymentInstructionsRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent the deposit addresses are reserved for. |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's stable id for the Acquirer; the Issuer resolves its settlement wallet from it. |
| amount_usdt | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt amount the reserved addresses should accept. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Absolute moment t-0 requires the reservation held until, on t-0's clock. t-0 sizes the window per intent rather than to a fixed value. |







<a name="tzero-v1-pay-issuer-CreatePaymentInstructionsResponse"></a>

### CreatePaymentInstructionsResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [CreatePaymentInstructionsResponse.Success](#tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Success) |  |  |
| failure | [CreatePaymentInstructionsResponse.Failure](#tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Failure) |  |  |







<a name="tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Failure"></a>

### CreatePaymentInstructionsResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [CreatePaymentInstructionsResponse.Failure.Reason](#tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Success"></a>

### CreatePaymentInstructionsResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| deposit_options | [tzero.v1.pay.DepositOption](../pay_common/#tzero-v1-pay-DepositOption) | repeated | One deposit option per chain the Issuer supports for this intent. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Absolute expiry of the reservation; must be at or after the requested expires_at, else t-0 discards the instructions and declines the payment. |







<a name="tzero-v1-pay-issuer-PaymentReceivedRequest"></a>

### PaymentReceivedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent the deposit was made against. |
| amount_usdt | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the deposit actually credited, on either outcome; the Issuer reports what arrived and t-0 runs the equality check itself. |
| usdt_on_chain | [tzero.v1.pay.UsdtOnChainPayment](../pay_common/#tzero-v1-pay-UsdtOnChainPayment) |  |  |
| received_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer observed the deposit as final on-chain. |
| authorized | [PaymentReceivedRequest.Authorized](#tzero-v1-pay-issuer-PaymentReceivedRequest-Authorized) |  |  |
| unprocessable | [PaymentReceivedRequest.Unprocessable](#tzero-v1-pay-issuer-PaymentReceivedRequest-Unprocessable) |  |  |







<a name="tzero-v1-pay-issuer-PaymentReceivedRequest-Authorized"></a>

### PaymentReceivedRequest.Authorized
The deposit passed the Issuer's screening. Once t-0 accepts the report the
Issuer owns the on-chain risk and is obligated to settle the intent.


This message has no fields defined.






<a name="tzero-v1-pay-issuer-PaymentReceivedRequest-Unprocessable"></a>

### PaymentReceivedRequest.Unprocessable
The Issuer will not process the deposit and the intent ends failed. The
disposition says where the funds go and is final when reported.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| disposition | [tzero.v1.pay.FundsDisposition](../pay_common/#tzero-v1-pay-FundsDisposition) |  | Where the funds go; final when reported. |







<a name="tzero-v1-pay-issuer-PaymentReceivedResponse"></a>

### PaymentReceivedResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [PaymentReceivedResponse.Accepted](#tzero-v1-pay-issuer-PaymentReceivedResponse-Accepted) |  |  |
| rejected | [PaymentReceivedResponse.Rejected](#tzero-v1-pay-issuer-PaymentReceivedResponse-Rejected) |  |  |







<a name="tzero-v1-pay-issuer-PaymentReceivedResponse-Accepted"></a>

### PaymentReceivedResponse.Accepted
The disposition is recorded.


This message has no fields defined.






<a name="tzero-v1-pay-issuer-PaymentReceivedResponse-Rejected"></a>

### PaymentReceivedResponse.Rejected
The report was not recorded.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [PaymentReceivedResponse.Rejected.Reason](#tzero-v1-pay-issuer-PaymentReceivedResponse-Rejected-Reason) |  |  |







<a name="tzero-v1-pay-issuer-SettlementSentRequest"></a>

### SettlementSentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| settlement_ref | [string](../scalar/#string) |  | Issuer's id for this USDt settlement; idempotency key, unique per Issuer. |
| amount_usdt | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Total USDt settled across the covered intents. |
| settlement | [tzero.v1.pay.OnChainSettlementDetails](../pay_common/#tzero-v1-pay-OnChainSettlementDetails) |  | On-chain transaction, chain, and registered destination wallet for this settlement. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents this settlement clears, treated as a set; per-intent amounts come from t-0's ledger. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer broadcast the settlement transaction. |







<a name="tzero-v1-pay-issuer-SettlementSentResponse"></a>

### SettlementSentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [SettlementSentResponse.Accepted](#tzero-v1-pay-issuer-SettlementSentResponse-Accepted) |  |  |
| rejected | [SettlementSentResponse.Rejected](#tzero-v1-pay-issuer-SettlementSentResponse-Rejected) |  |  |







<a name="tzero-v1-pay-issuer-SettlementSentResponse-Accepted"></a>

### SettlementSentResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-issuer-SettlementSentResponse-Rejected"></a>

### SettlementSentResponse.Rejected
The settlement is not recorded. ON_CHAIN_UNCONFIRMED clears on its own and
the report is resubmitted under the same settlement_ref once the transaction
confirms; the other reasons open a manual reconciliation with t-0, and the
corrected report follows from it.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [SettlementSentResponse.Rejected.Reason](#tzero-v1-pay-issuer-SettlementSentResponse-Rejected-Reason) |  |  |






 <!-- end messages -->


<a name="tzero-v1-pay-issuer-CreatePaymentInstructionsResponse-Failure-Reason"></a>

### CreatePaymentInstructionsResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ISSUER_UNAVAILABLE | 10 | The Issuer is unavailable to allocate. |
| REASON_ADDRESS_POOL_EMPTY | 20 | No free one-time deposit addresses. |
| REASON_AMOUNT_OUT_OF_RANGE | 40 | The amount falls outside the acceptable range. |



<a name="tzero-v1-pay-issuer-PaymentReceivedResponse-Rejected-Reason"></a>

### PaymentReceivedResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_INTENT_EXPIRED | 10 | Processing started after expires_at on t-0's clock. |
| REASON_UNKNOWN_INTENT | 20 | No such intent exists, or another Issuer serves it. |
| REASON_AMOUNT_MISMATCH | 30 | amount_usdt is not exactly the intent's stored amount; authorized outcome only. |
| REASON_TRANSFER_RECORDED_FOR_ANOTHER_INTENT | 40 | The transfer is already another intent's recorded deposit; no refund or disposition action follows — reconciled out of band. |



<a name="tzero-v1-pay-issuer-SettlementSentResponse-Rejected-Reason"></a>

### SettlementSentResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ON_CHAIN_UNCONFIRMED | 10 | The on-chain transaction is not yet confirmed. Not returned in the MVP, where t-0 records the settlement on the Issuer's report without on-chain verification. |
| REASON_AMOUNT_MISMATCH | 20 | The confirmed amount does not equal amount_usdt or the covered intents' sum. |
| REASON_WRONG_DESTINATION | 30 | destination_address (or its chain) is not the expected registered (chain, address) pair for the mode. |
| REASON_INTENT_NOT_SETTLEABLE | 40 | A listed intent is unknown, not authorized, or already covered. Fiat mode also accepts a settled intent, whose Acquirer confirmation may land before this reimbursement. |
| REASON_SETTLEMENT_REF_CONFLICT | 50 | This on-chain transfer is already recorded under a different settlement_ref. |


 <!-- end enums -->


