---
weight: 331
title: "Acquirer"
description: ""
icon: "article"
date: "2025-06-16T12:09:09+02:00"
lastmod: "2025-06-16T12:09:09+02:00"
draft: false
toc: true
---

<a name="tzero-v1-pay-AcquirerCallbackService"></a>

## AcquirerCallbackService
Acquirer-implemented callbacks t-0 pushes — authorization, settlement
progress, and expiry. Delivered at least once and deduped on the t-0 id.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PaymentAuthorized | [PaymentAuthorizedRequest](#tzero-v1-pay-PaymentAuthorizedRequest) | [PaymentAuthorizedResponse](#tzero-v1-pay-PaymentAuthorizedResponse) | Tells the merchant the sale is approved; from here the Issuer is obligated to settle. |
| SettlementInitiated | [SettlementInitiatedRequest](#tzero-v1-pay-SettlementInitiatedRequest) | [SettlementInitiatedResponse](#tzero-v1-pay-SettlementInitiatedResponse) | Pre-notice that the LP sent a fiat bank transfer, naming the reference to expect. |
| SettlementCompleted | [SettlementCompletedRequest](#tzero-v1-pay-SettlementCompletedRequest) | [SettlementCompletedResponse](#tzero-v1-pay-SettlementCompletedResponse) | Settlement verified on-chain as reached the Acquirer (USDt mode only); lists the intents it clears. |
| PaymentExpired | [AcquirerPaymentExpiredRequest](#tzero-v1-pay-AcquirerPaymentExpiredRequest) | [AcquirerPaymentExpiredResponse](#tzero-v1-pay-AcquirerPaymentExpiredResponse) | Intent expired with no payment; clear the pending order and drop the QR. |


<a name="tzero-v1-pay-AcquirerService"></a>

## AcquirerService
t-0 endpoints the Acquirer calls to price a sale, open a payment intent, and
confirm fiat receipt.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| GetPaymentQuote | [GetPaymentQuoteRequest](#tzero-v1-pay-GetPaymentQuoteRequest) | [GetPaymentQuoteResponse](#tzero-v1-pay-GetPaymentQuoteResponse) | Prices an upcoming fiat sale from t-0's Order Book of standing LP quotes. |
| CreatePaymentIntent | [CreatePaymentIntentRequest](#tzero-v1-pay-CreatePaymentIntentRequest) | [CreatePaymentIntentResponse](#tzero-v1-pay-CreatePaymentIntentResponse) | Opens a payment intent for a sale; t-0 calls the Issuer inline and returns QR options. |
| SettlementReceived | [SettlementReceivedRequest](#tzero-v1-pay-SettlementReceivedRequest) | [SettlementReceivedResponse](#tzero-v1-pay-SettlementReceivedResponse) | Confirms fiat settlement landed in the Acquirer's bank account — the oracle for the bank leg. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-AcquirerPaymentExpiredRequest"></a>

### AcquirerPaymentExpiredRequest
`PaymentExpired` is also a method on IssuerService in this flat
package, so the request/response carry a role prefix to avoid a colliding
`PaymentExpiredRequest`. Interim name: buf STANDARD RPC_REQUEST_STANDARD_NAME
accepts only bare `PaymentExpiredRequest` or the full
`AcquirerCallbackServicePaymentExpiredRequest`, so this short form needs a
lint ignore at graduation (or rename the method).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  |  |
| payment_ref | [string](../scalar/#string) |  | Echo of the Acquirer's CreatePaymentIntent payment_ref. |
| local_currency | [string](../scalar/#string) |  |  |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| expired_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the intent became terminal. |







<a name="tzero-v1-pay-AcquirerPaymentExpiredResponse"></a>

### AcquirerPaymentExpiredResponse



This message has no fields defined.






<a name="tzero-v1-pay-CreatePaymentIntentRequest"></a>

### CreatePaymentIntentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_ref | [string](../scalar/#string) |  | Sale identifier the Acquirer keeps in its own ledger; idempotency key, unique per Acquirer. |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| usdt_settlement | [CreatePaymentIntentRequest.UsdtSettlementTerms](#tzero-v1-pay-CreatePaymentIntentRequest-UsdtSettlementTerms) |  |  |
| fiat_settlement | [CreatePaymentIntentRequest.FiatSettlementTerms](#tzero-v1-pay-CreatePaymentIntentRequest-FiatSettlementTerms) |  |  |







<a name="tzero-v1-pay-CreatePaymentIntentRequest-FiatSettlementTerms"></a>

### CreatePaymentIntentRequest.FiatSettlementTerms
Reference to a standing quote when the Acquirer is settled in fiat via an LP.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_id | [uint64](../scalar/#uint64) |  | Standing quote obtained from GetPaymentQuote; supplies local_currency and fx_rate. |







<a name="tzero-v1-pay-CreatePaymentIntentRequest-UsdtSettlementTerms"></a>

### CreatePaymentIntentRequest.UsdtSettlementTerms
Acquirer-supplied terms when it settles in USDt and runs its own FX.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency the merchant quoted the customer in. |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Units of local_currency per 1 USDt, set by the Acquirer. |







<a name="tzero-v1-pay-CreatePaymentIntentResponse"></a>

### CreatePaymentIntentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [CreatePaymentIntentResponse.Success](#tzero-v1-pay-CreatePaymentIntentResponse-Success) |  |  |
| failure | [CreatePaymentIntentResponse.Failure](#tzero-v1-pay-CreatePaymentIntentResponse-Failure) |  |  |







<a name="tzero-v1-pay-CreatePaymentIntentResponse-Failure"></a>

### CreatePaymentIntentResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [CreatePaymentIntentResponse.Failure.Reason](#tzero-v1-pay-CreatePaymentIntentResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-CreatePaymentIntentResponse-Success"></a>

### CreatePaymentIntentResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  |  |
| local_currency | [string](../scalar/#string) |  | ISO 4217; echoed in USDt mode, resolved from the quote in fiat mode. |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Exact amount the customer pays, round(local_amount / fx_rate, 2dp, half-up). |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | After this moment the Issuer releases the deposit addresses and the QR is invalid. |
| qr_options | [QrOption](../pay_types/#tzero-v1-pay-QrOption) | repeated | One option per chain the Issuer supports for this intent; the customer picks one. |







<a name="tzero-v1-pay-GetPaymentQuoteRequest"></a>

### GetPaymentQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency the merchant is quoting in (e.g. COP). |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |







<a name="tzero-v1-pay-GetPaymentQuoteResponse"></a>

### GetPaymentQuoteResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [GetPaymentQuoteResponse.Success](#tzero-v1-pay-GetPaymentQuoteResponse-Success) |  |  |
| failure | [GetPaymentQuoteResponse.Failure](#tzero-v1-pay-GetPaymentQuoteResponse-Failure) |  |  |







<a name="tzero-v1-pay-GetPaymentQuoteResponse-Failure"></a>

### GetPaymentQuoteResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [GetPaymentQuoteResponse.Failure.Reason](#tzero-v1-pay-GetPaymentQuoteResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-GetPaymentQuoteResponse-Success"></a>

### GetPaymentQuoteResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_id | [uint64](../scalar/#uint64) |  |  |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Standing quote's rate, in units of local_currency per 1 USDt. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the standing quote stops standing on t-0's clock. |







<a name="tzero-v1-pay-PaymentAuthorizedRequest"></a>

### PaymentAuthorizedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  |  |
| payment_ref | [string](../scalar/#string) |  | Echo of the Acquirer's CreatePaymentIntent payment_ref, to match the merchant order. |
| local_currency | [string](../scalar/#string) |  |  |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| usdt_on_chain | [UsdtOnChainPayment](../pay_types/#tzero-v1-pay-UsdtOnChainPayment) |  |  |
| approved_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 accepted PaymentReceived. |







<a name="tzero-v1-pay-PaymentAuthorizedResponse"></a>

### PaymentAuthorizedResponse



This message has no fields defined.






<a name="tzero-v1-pay-SettlementCompletedRequest"></a>

### SettlementCompletedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| settlement_id | [uint64](../scalar/#uint64) |  |  |
| settlement_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Amount the Acquirer actually received; currency set by the settlement variant. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated |  |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  |  |
| settlement | [OnChainSettlementDetails](../pay_types/#tzero-v1-pay-OnChainSettlementDetails) |  | The on-chain USDt settlement that reached the Acquirer. USDt mode only — fiat mode has no SettlementCompleted (the Acquirer's SettlementReceived is terminal). |







<a name="tzero-v1-pay-SettlementCompletedResponse"></a>

### SettlementCompletedResponse



This message has no fields defined.






<a name="tzero-v1-pay-SettlementInitiatedRequest"></a>

### SettlementInitiatedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| fiat_settlement_id | [uint64](../scalar/#uint64) |  | t-0's id for this fiat settlement (the fiatSettlementId); the bank-rails leg's key. |
| lp_id | [uint64](../scalar/#uint64) |  | t-0's id for the LP that sent the transfer; scopes bank_transfer_ref. |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference the LP put on the bank-rails transfer; matched against the statement. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents this settlement clears, resolved by t-0 from the LP's executions. |
| local_currency | [string](../scalar/#string) |  |  |
| settlement_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| initiated_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  |  |







<a name="tzero-v1-pay-SettlementInitiatedResponse"></a>

### SettlementInitiatedResponse



This message has no fields defined.






<a name="tzero-v1-pay-SettlementReceivedRequest"></a>

### SettlementReceivedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lp_id | [uint64](../scalar/#uint64) |  | t-0's id for the LP that sent the transfer, echoed from SettlementInitiated. |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference on the received transfer, matched against the bank statement. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency credited. |
| amount_received | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  |  |
| received_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  |  |







<a name="tzero-v1-pay-SettlementReceivedResponse"></a>

### SettlementReceivedResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [SettlementReceivedResponse.Accepted](#tzero-v1-pay-SettlementReceivedResponse-Accepted) |  |  |
| rejected | [SettlementReceivedResponse.Rejected](#tzero-v1-pay-SettlementReceivedResponse-Rejected) |  |  |







<a name="tzero-v1-pay-SettlementReceivedResponse-Accepted"></a>

### SettlementReceivedResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-SettlementReceivedResponse-Rejected"></a>

### SettlementReceivedResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [SettlementReceivedResponse.Rejected.Reason](#tzero-v1-pay-SettlementReceivedResponse-Rejected-Reason) |  |  |






 <!-- end messages -->


<a name="tzero-v1-pay-CreatePaymentIntentResponse-Failure-Reason"></a>

### CreatePaymentIntentResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ISSUER_UNAVAILABLE | 10 | The Issuer could not be reached to allocate instructions. |
| REASON_ADDRESS_POOL_EMPTY | 20 | The Issuer has no free one-time deposit addresses. |
| REASON_AMOUNT_OUT_OF_RANGE | 40 | The amount falls outside the acceptable range. |
| REASON_QUOTE_EXPIRED | 50 | The referenced quote no longer stands. |
| REASON_QUOTE_INSUFFICIENT_HEADROOM | 70 | The quote's remaining validity is too short to guarantee execution before it expires. |



<a name="tzero-v1-pay-GetPaymentQuoteResponse-Failure-Reason"></a>

### GetPaymentQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_QUOTE_UNAVAILABLE | 10 | No standing quote available for this currency (LP not quoting it now, or not enabled for this Acquirer). |
| REASON_AMOUNT_OUT_OF_RANGE | 30 | No standing quote's per-sale USDt bounds cover the request amount. |



<a name="tzero-v1-pay-SettlementReceivedResponse-Rejected-Reason"></a>

### SettlementReceivedResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_AMOUNT_MISMATCH | 10 | amount_received does not equal the matched transfer's settlement amount. |
| REASON_UNKNOWN_TRANSFER | 20 | No fiat settlement matches the (lp_id, bank_transfer_ref) pair. |


 <!-- end enums -->


