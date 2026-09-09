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

<a name="tzero-v1-pay-acquirer-AcquirerCallbackService"></a>

## AcquirerCallbackService
Acquirer-implemented callbacks t-0 pushes: authorization, settlement
progress, expiry, and payment failure. Each is delivered to the Acquirer's
registered callback URL at least once; the Acquirer dedupes on the t-0-minted
id it carries.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PaymentAuthorized | [PaymentAuthorizedRequest](#tzero-v1-pay-acquirer-PaymentAuthorizedRequest) | [PaymentAuthorizedResponse](#tzero-v1-pay-acquirer-PaymentAuthorizedResponse) | Tells the merchant the payment is approved; from here the Issuer is obligated to settle. |
| SettlementInitiated | [SettlementInitiatedRequest](#tzero-v1-pay-acquirer-SettlementInitiatedRequest) | [SettlementInitiatedResponse](#tzero-v1-pay-acquirer-SettlementInitiatedResponse) | Pre-notice that the LP sent a fiat bank transfer, naming the reference to expect; fiat settlement mode only, and does not settle the intents. |
| SettlementCompleted | [SettlementCompletedRequest](#tzero-v1-pay-acquirer-SettlementCompletedRequest) | [SettlementCompletedResponse](#tzero-v1-pay-acquirer-SettlementCompletedResponse) | The Issuer's USDt settlement verified on-chain as reaching the Acquirer's wallet, with the intents it clears; USDt settlement mode only — in fiat mode the Acquirer's own SettlementReceived is the terminal event. |
| PaymentExpired | [PaymentExpiredRequest](#tzero-v1-pay-acquirer-PaymentExpiredRequest) | [PaymentExpiredResponse](#tzero-v1-pay-acquirer-PaymentExpiredResponse) | The QR window lapsed with no payment; clear the pending order and drop the QR. |
| PaymentFailed | [PaymentFailedRequest](#tzero-v1-pay-acquirer-PaymentFailedRequest) | [PaymentFailedResponse](#tzero-v1-pay-acquirer-PaymentFailedResponse) | A deposit arrived that the Issuer will not process; the payment is over and will not settle. |


<a name="tzero-v1-pay-acquirer-AcquirerService"></a>

## AcquirerService
t-0 endpoints the Acquirer calls to price a payment, open a payment intent, and
confirm fiat receipt.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| GetPaymentQuote | [GetPaymentQuoteRequest](#tzero-v1-pay-acquirer-GetPaymentQuoteRequest) | [GetPaymentQuoteResponse](#tzero-v1-pay-acquirer-GetPaymentQuoteResponse) | Prices an upcoming local-fiat payment from t-0's Order Book of standing LP quotes; fiat settlement mode only. |
| CreatePaymentIntent | [CreatePaymentIntentRequest](#tzero-v1-pay-acquirer-CreatePaymentIntentRequest) | [CreatePaymentIntentResponse](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse) | Opens a payment intent; t-0 reserves deposit addresses with the Issuer inline and returns the payment instructions. |
| SettlementReceived | [SettlementReceivedRequest](#tzero-v1-pay-acquirer-SettlementReceivedRequest) | [SettlementReceivedResponse](#tzero-v1-pay-acquirer-SettlementReceivedResponse) | Confirms that a fiat settlement landed in the Acquirer's bank account; fiat settlement mode only, and the only event that settles the covered intents. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-acquirer-CreatePaymentIntentRequest"></a>

### CreatePaymentIntentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_ref | [string](../scalar/#string) |  | Payment identifier from the Acquirer's own ledger, echoed on PaymentAuthorized, PaymentExpired, and PaymentFailed. Not an idempotency key, and not required to be unique. |
| idempotency_key | [string](../scalar/#string) |  | Retry identity for this call, unique per Acquirer. At most one payment intent is ever created under one key, and repeating a key whose intent exists returns it unchanged. Retrying a declined payment takes a fresh key under the same payment_ref. |
| settlement | [CreatePaymentIntentRequest.SettlementAmount](#tzero-v1-pay-acquirer-CreatePaymentIntentRequest-SettlementAmount) |  |  |
| local | [LocalAmount](#tzero-v1-pay-acquirer-LocalAmount) |  |  |
| quote_id | [uint64](../scalar/#uint64) |  | A standing quote from GetPaymentQuote; it must still stand, and its currency must equal local.currency when `local` is given.  Reserved, not on the wire yet: `quote_currency`, pricing by the freshest standing quote for a named currency. |







<a name="tzero-v1-pay-acquirer-CreatePaymentIntentRequest-SettlementAmount"></a>

### CreatePaymentIntentRequest.SettlementAmount
The payment in the settlement asset, USDt: the asset every settlement leg
moves, so this figure is present for every payment whatever the Acquirer is
settled in. What it becomes in fiat, and at which rate, is the response's
`fiat` settlement block, never this message.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| value | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Amount in USDt, at most 2 decimal places. In fiat settlement mode t-0 derives the local amount from it at the locked rate; in USDt settlement mode it is also what the Acquirer is settled. |







<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse"></a>

### CreatePaymentIntentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [CreatePaymentIntentResponse.Success](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success) |  |  |
| failure | [CreatePaymentIntentResponse.Failure](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Failure) |  |  |







<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Failure"></a>

### CreatePaymentIntentResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [CreatePaymentIntentResponse.Failure.Reason](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success"></a>

### CreatePaymentIntentResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | t-0's id for the intent; carried on every later event. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | After this moment the payment instructions are invalid; on the QR method the Issuer releases the deposit addresses. |
| settlement_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the customer pays and the settlement leg moves, the same figure in every mode: as sent in `amount.settlement`, or round(local / fx_rate, 2 dp, half-up) from `amount.local`. In fiat settlement mode the Acquirer itself receives the `fiat` block's local amount. |
| usdt_on_chain | [CreatePaymentIntentResponse.Success.UsdtOnChainInstructions](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success-UsdtOnChainInstructions) |  |  |
| fiat | [FiatSettlement](#tzero-v1-pay-acquirer-FiatSettlement) |  |  |
| onchain | [CreatePaymentIntentResponse.Success.OnchainSettlement](#tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success-OnchainSettlement) |  |  |







<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success-OnchainSettlement"></a>

### CreatePaymentIntentResponse.Success.OnchainSettlement
On-chain settlement mode; carries no data. The Issuer settles
settlement_amount in USDt to the Acquirer's registered wallet; no quote
and no FX.


This message has no fields defined.






<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Success-UsdtOnChainInstructions"></a>

### CreatePaymentIntentResponse.Success.UsdtOnChainInstructions
The customer's USDt-via-QR payment instructions.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| deposit_options | [tzero.v1.pay.DepositOption](../pay_common/#tzero-v1-pay-DepositOption) | repeated | One deposit option per chain the Issuer supports for this intent; the customer picks one in their wallet. |







<a name="tzero-v1-pay-acquirer-FiatSettlement"></a>

### FiatSettlement
The fiat terms locked for a payment whose Acquirer is settled in fiat: the
standing quote, its rate, and the local amount the Acquirer is settled.
Returned on CreatePaymentIntent and repeated unchanged on PaymentAuthorized,
PaymentExpired and PaymentFailed; absent for an Acquirer settled on-chain.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id of the standing quote the intent locked: the referenced one, or the one t-0 resolved when the request named none. |
| fx_rate | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Locked rate, in units of local.currency per 1 USDt. |
| local | [LocalAmount](#tzero-v1-pay-acquirer-LocalAmount) |  | Fiat amount the Acquirer is settled: as sent in the request's `local`, or, for a payment denominated in USDt, round(settlement_amount × fx_rate, half-up) to the currency's minor units. |







<a name="tzero-v1-pay-acquirer-GetPaymentQuoteRequest"></a>

### GetPaymentQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| local_currency | [string](../scalar/#string) |  | Three-letter currency code in ISO 4217 form the merchant is quoting in (e.g. COP); not checked against the ISO list. |
| local_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Fiat amount in local_currency to price; a value finer than the currency's minor units is invalid input. |







<a name="tzero-v1-pay-acquirer-GetPaymentQuoteResponse"></a>

### GetPaymentQuoteResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [GetPaymentQuoteResponse.Success](#tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Success) |  |  |
| failure | [GetPaymentQuoteResponse.Failure](#tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Failure) |  |  |







<a name="tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Failure"></a>

### GetPaymentQuoteResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [GetPaymentQuoteResponse.Failure.Reason](#tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Success"></a>

### GetPaymentQuoteResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote that priced this request; not consumed by use, any number of intents may reference it while it stands. |
| settlement_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | The payment in the settlement asset (USDt): round(local_amount / fx_rate, 2 dp, half-up). Indicative; the binding figure is derived the same way on CreatePaymentIntent. |
| fx_rate | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Standing quote's rate, in units of local_currency per 1 USDt. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the quote stops standing, on t-0's clock; it cannot be referenced after this. |







<a name="tzero-v1-pay-acquirer-LocalAmount"></a>

### LocalAmount
An amount in the local fiat currency the customer was quoted in. Minor units
are t-0's own rule, not ISO 4217's: COP, CLP, PYG and JPY are kept in whole
units, every other currency at two decimal places.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| value | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Amount in `currency`; a value finer than the currency's minor units is invalid input. |
| currency | [string](../scalar/#string) |  | Three-letter currency code in ISO 4217 form (e.g. COP); not checked against the ISO list. |







<a name="tzero-v1-pay-acquirer-PaymentAuthorizedRequest"></a>

### PaymentAuthorizedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent that was authorized. |
| payment_ref | [string](../scalar/#string) |  | Echo of the CreatePaymentIntent payment_ref, so the merchant order can be matched by it or by payment_intent_id. |
| usdt_on_chain | [tzero.v1.pay.UsdtOnChainPayment](../pay_common/#tzero-v1-pay-UsdtOnChainPayment) |  |  |
| approved_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 accepted the Issuer's report and authorized the payment. |
| settlement_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the deposit credited; equals the intent's settlement_amount, stated so the Acquirer's ledger derives nothing. |
| received_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the Issuer observed the deposit final on-chain. |
| fiat_settlement | [FiatSettlement](#tzero-v1-pay-acquirer-FiatSettlement) |  | no validation: absent for an Acquirer settled on-chain, so no presence rule applies. |







<a name="tzero-v1-pay-acquirer-PaymentAuthorizedResponse"></a>

### PaymentAuthorizedResponse



This message has no fields defined.






<a name="tzero-v1-pay-acquirer-PaymentExpiredRequest"></a>

### PaymentExpiredRequest
The QR window lapsed on t-0's clock with no payment reported; the payment is
over and nothing will settle for it.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent that expired. |
| payment_ref | [string](../scalar/#string) |  | Echo of the CreatePaymentIntent payment_ref, alongside payment_intent_id. |
| expired_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the intent expired on t-0's clock. |
| fiat_settlement | [FiatSettlement](#tzero-v1-pay-acquirer-FiatSettlement) |  | no validation: absent for an Acquirer settled on-chain, so no presence rule applies. |







<a name="tzero-v1-pay-acquirer-PaymentExpiredResponse"></a>

### PaymentExpiredResponse



This message has no fields defined.






<a name="tzero-v1-pay-acquirer-PaymentFailedRequest"></a>

### PaymentFailedRequest
A customer deposit against this intent will not settle and the intent is
terminally failed: clear the pending order and drop the QR. Sent only while
the QR window is still open; once an intent has expired, its expiry notice is
the last word on that payment.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| payment_intent_id | [uint64](../scalar/#uint64) |  | Intent the deposit was made against. |
| payment_ref | [string](../scalar/#string) |  | Echo of the CreatePaymentIntent payment_ref, alongside payment_intent_id. |
| amount_usdt | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the deposit credited, as reported by the Issuer; may differ from the intent's settlement_amount. |
| usdt_on_chain | [tzero.v1.pay.UsdtOnChainPayment](../pay_common/#tzero-v1-pay-UsdtOnChainPayment) |  |  |
| disposition | [tzero.v1.pay.FundsDisposition](../pay_common/#tzero-v1-pay-FundsDisposition) |  | Where the funds go, so the merchant can tell the customer what to expect. |
| failed_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the intent became terminally failed. |
| fiat_settlement | [FiatSettlement](#tzero-v1-pay-acquirer-FiatSettlement) |  | no validation: absent for an Acquirer settled on-chain, so no presence rule applies. |







<a name="tzero-v1-pay-acquirer-PaymentFailedResponse"></a>

### PaymentFailedResponse



This message has no fields defined.






<a name="tzero-v1-pay-acquirer-SettlementCompletedRequest"></a>

### SettlementCompletedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| settlement_id | [uint64](../scalar/#uint64) |  | t-0's id for this on-chain settlement; the Acquirer dedupes on it. |
| settlement_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt amount that reached the Acquirer's wallet. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents this settlement clears. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 verified the settlement final on-chain. |
| settlement | [tzero.v1.pay.OnChainSettlementDetails](../pay_common/#tzero-v1-pay-OnChainSettlementDetails) |  | The on-chain USDt transfer that reached the Acquirer's registered wallet. |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's id for the Acquirer this settlement is addressed to. |







<a name="tzero-v1-pay-acquirer-SettlementCompletedResponse"></a>

### SettlementCompletedResponse



This message has no fields defined.






<a name="tzero-v1-pay-acquirer-SettlementInitiatedRequest"></a>

### SettlementInitiatedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| fiat_settlement_id | [uint64](../scalar/#uint64) |  | t-0's id for this fiat settlement; the Acquirer dedupes on it. |
| lp_id | [uint64](../scalar/#uint64) |  | t-0's id for the LP that sent the transfer; scopes bank_transfer_ref. |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference the LP put on the bank-rails transfer; matched against the statement. |
| settled_payment_intent_ids | [uint64](../scalar/#uint64) | repeated | Intents this settlement clears; the Acquirer maps them to its own payment_refs. |
| local | [LocalAmount](#tzero-v1-pay-acquirer-LocalAmount) |  | Fiat amount and currency of the bank-rails transfer the LP reported; SettlementReceived must confirm exactly this figure. |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's id for the Acquirer this settlement is addressed to. |
| initiated_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 accepted the LP's fiat-settlement report. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the LP reported completing the bank-rails transfer — the value date to match on the statement. |







<a name="tzero-v1-pay-acquirer-SettlementInitiatedResponse"></a>

### SettlementInitiatedResponse



This message has no fields defined.






<a name="tzero-v1-pay-acquirer-SettlementReceivedRequest"></a>

### SettlementReceivedRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lp_id | [uint64](../scalar/#uint64) |  | t-0's id for the LP that sent the transfer, echoed from SettlementInitiated. |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference on the received transfer, matched against the bank statement. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency credited. |
| amount_received | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Fiat amount credited to the Acquirer's account. |
| received_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the funds landed in the Acquirer's account. |







<a name="tzero-v1-pay-acquirer-SettlementReceivedResponse"></a>

### SettlementReceivedResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [SettlementReceivedResponse.Accepted](#tzero-v1-pay-acquirer-SettlementReceivedResponse-Accepted) |  |  |
| rejected | [SettlementReceivedResponse.Rejected](#tzero-v1-pay-acquirer-SettlementReceivedResponse-Rejected) |  |  |







<a name="tzero-v1-pay-acquirer-SettlementReceivedResponse-Accepted"></a>

### SettlementReceivedResponse.Accepted
The confirmation is recorded and the covered intents are settled.


This message has no fields defined.






<a name="tzero-v1-pay-acquirer-SettlementReceivedResponse-Rejected"></a>

### SettlementReceivedResponse.Rejected
The confirmation was not recorded and the covered intents stay authorized; resubmit the same (lp_id, bank_transfer_ref) with corrected fields.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [SettlementReceivedResponse.Rejected.Reason](#tzero-v1-pay-acquirer-SettlementReceivedResponse-Rejected-Reason) |  |  |






 <!-- end messages -->


<a name="tzero-v1-pay-acquirer-CreatePaymentIntentResponse-Failure-Reason"></a>

### CreatePaymentIntentResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_ISSUER_UNAVAILABLE | 10 | The Issuer could not be reached, or returned no usable instructions. |
| REASON_ADDRESS_POOL_EMPTY | 20 | The Issuer has no free one-time deposit addresses. |
| REASON_AMOUNT_OUT_OF_RANGE | 40 | The amount falls outside the acceptable range. |
| REASON_QUOTE_EXPIRED | 50 | The referenced quote no longer stands. |
| REASON_QUOTE_INSUFFICIENT_HEADROOM | 70 | The quote's remaining validity is too short to guarantee execution before it expires. |
| REASON_QUOTE_UNAVAILABLE | 80 | No standing quote for the payment's currency right now (quote_id omitted). |



<a name="tzero-v1-pay-acquirer-GetPaymentQuoteResponse-Failure-Reason"></a>

### GetPaymentQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_QUOTE_UNAVAILABLE | 10 | No standing quote available for this currency right now. |



<a name="tzero-v1-pay-acquirer-SettlementReceivedResponse-Rejected-Reason"></a>

### SettlementReceivedResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_AMOUNT_MISMATCH | 10 | amount_received does not equal the settlement_amount announced on SettlementInitiated. |
| REASON_UNKNOWN_TRANSFER | 20 | No fiat settlement matches the (lp_id, bank_transfer_ref) pair. |
| REASON_CURRENCY_MISMATCH | 30 | local_currency is not the currency announced on SettlementInitiated for the matched transfer. |


 <!-- end enums -->


