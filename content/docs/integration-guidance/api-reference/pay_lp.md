---
weight: 333
title: "Liquidity Provider"
description: ""
icon: "article"
date: "2025-06-16T12:09:09+02:00"
lastmod: "2025-06-16T12:09:09+02:00"
draft: false
toc: true
---

<a name="tzero-v1-pay-lp-LpCallbackService"></a>

## LpCallbackService
LP-implemented endpoint t-0 calls to request the LP's durable decision on a
standing quote execution for one authorized payment. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| ExecuteQuote | [ExecuteQuoteRequest](#tzero-v1-pay-lp-ExecuteQuoteRequest) | [ExecuteQuoteResponse](#tzero-v1-pay-lp-ExecuteQuoteResponse) | Requests a durable Accepted or Rejected result; only Accepted creates the LP's firm per-payment obligation. |


<a name="tzero-v1-pay-lp-LpService"></a>

## LpService
t-0 endpoints the LP calls to push standing quotes and to report its
self-initiated fiat settlements. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PublishQuote | [PublishQuoteRequest](#tzero-v1-pay-lp-PublishQuoteRequest) | [PublishQuoteResponse](#tzero-v1-pay-lp-PublishQuoteResponse) | Pushes immutable standing quotes into t-0's Order Book, at most one per currency per call; each is multi-consumable while it stands. |
| FiatSettlementSent | [FiatSettlementSentRequest](#tzero-v1-pay-lp-FiatSettlementSentRequest) | [FiatSettlementSentResponse](#tzero-v1-pay-lp-FiatSettlementSentResponse) | Reports a fiat bank-rails settlement the LP made on its own initiative against accepted quote executions. An execution still awaiting its durable result returns FAILED_PRECONDITION; retry the same request. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-lp-ExecuteQuoteRequest"></a>

### ExecuteQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| execution_id | [uint64](../scalar/#uint64) |  | t-0's id for this execution command; idempotency key and, after Accepted, the LP's obligation handle. |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote this execution is under. |
| quote_ref | [string](../scalar/#string) |  | The LP's own quote_ref for that quote, echoed so the LP can attribute the execution even before it has recorded t-0's quote_id. |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's stable id for the Acquirer whose local-fiat obligation is being executed. |
| local_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Fiat amount owed to the Acquirer for this payment, in the standing quote's currency. |
| amount_usdt | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the LP receives at settlement for this payment. |
| executed_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 created this durable execution command at authorization. |
| local_currency | [string](../scalar/#string) |  | Currency of local_amount — the standing quote's. |
| fx_rate | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | The standing quote's rate, in units of local_currency per 1 USDt, locked for this payment. |







<a name="tzero-v1-pay-lp-ExecuteQuoteResponse"></a>

### ExecuteQuoteResponse
The LP's durable decision on one ExecuteQuote command.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [ExecuteQuoteResponse.Accepted](#tzero-v1-pay-lp-ExecuteQuoteResponse-Accepted) |  | The LP accepts the execution. |
| rejected | [ExecuteQuoteResponse.Rejected](#tzero-v1-pay-lp-ExecuteQuoteResponse-Rejected) |  | The LP declines the execution. |







<a name="tzero-v1-pay-lp-ExecuteQuoteResponse-Accepted"></a>

### ExecuteQuoteResponse.Accepted
Acceptance creates the LP's firm per-payment obligation.


This message has no fields defined.






<a name="tzero-v1-pay-lp-ExecuteQuoteResponse-Rejected"></a>

### ExecuteQuoteResponse.Rejected
Rejection leaves the payment intent authorized for manual handling.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [ExecuteQuoteResponse.Rejected.Reason](#tzero-v1-pay-lp-ExecuteQuoteResponse-Rejected-Reason) |  | Stable business classification for declining the command. |
| details | [string](../scalar/#string) |  | Human-readable business details for declining the command. |







<a name="tzero-v1-pay-lp-FiatSettlementSentRequest"></a>

### FiatSettlementSentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference on the bank-rails transfer; idempotency key, unique per LP. |
| settled_execution_ids | [uint64](../scalar/#uint64) | repeated | Accepted executions this settlement clears, treated as a set (duplicates collapse, order is not significant). |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency delivered; matches the covered executions' currency. |
| settlement_amount | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Local-fiat amount delivered; must equal the sum of the covered executions' local amounts. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the LP released the bank-rails transfer. |







<a name="tzero-v1-pay-lp-FiatSettlementSentResponse"></a>

### FiatSettlementSentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [FiatSettlementSentResponse.Accepted](#tzero-v1-pay-lp-FiatSettlementSentResponse-Accepted) |  |  |
| rejected | [FiatSettlementSentResponse.Rejected](#tzero-v1-pay-lp-FiatSettlementSentResponse-Rejected) |  |  |







<a name="tzero-v1-pay-lp-FiatSettlementSentResponse-Accepted"></a>

### FiatSettlementSentResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-lp-FiatSettlementSentResponse-Rejected"></a>

### FiatSettlementSentResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [FiatSettlementSentResponse.Rejected.Reason](#tzero-v1-pay-lp-FiatSettlementSentResponse-Rejected-Reason) |  |  |







<a name="tzero-v1-pay-lp-PublishQuoteRequest"></a>

### PublishQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quotes | [PublishQuoteRequest.Quote](#tzero-v1-pay-lp-PublishQuoteRequest-Quote) | repeated | Standing quotes to publish in one call, at most one per currency, each under its own quote_ref. The batch is atomic: one invalid quote declines the whole call and consumes no quote_ref. |







<a name="tzero-v1-pay-lp-PublishQuoteRequest-Quote"></a>

### PublishQuoteRequest.Quote



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_ref | [string](../scalar/#string) |  | LP's identifier for this quote; idempotency key, unique per LP. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency the quote prices (e.g. COP). |
| fx_rate | [tzero.v1.pay.Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Published rate, in units of local_currency per 1 USDt. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the quote stops standing, on t-0's clock. Validity bounds are a business decline (VALIDITY_INVALID), not request validation. |







<a name="tzero-v1-pay-lp-PublishQuoteResponse"></a>

### PublishQuoteResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [PublishQuoteResponse.Success](#tzero-v1-pay-lp-PublishQuoteResponse-Success) |  |  |
| failure | [PublishQuoteResponse.Failure](#tzero-v1-pay-lp-PublishQuoteResponse-Failure) |  |  |







<a name="tzero-v1-pay-lp-PublishQuoteResponse-Failure"></a>

### PublishQuoteResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [PublishQuoteResponse.Failure.Reason](#tzero-v1-pay-lp-PublishQuoteResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-lp-PublishQuoteResponse-Success"></a>

### PublishQuoteResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quotes | [PublishQuoteResponse.Success.PublishedQuote](#tzero-v1-pay-lp-PublishQuoteResponse-Success-PublishedQuote) | repeated | One entry per published quote, in request order. |







<a name="tzero-v1-pay-lp-PublishQuoteResponse-Success-PublishedQuote"></a>

### PublishQuoteResponse.Success.PublishedQuote



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_ref | [string](../scalar/#string) |  | Echo of the quote's quote_ref. |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote, used everywhere downstream. |






 <!-- end messages -->


<a name="tzero-v1-pay-lp-ExecuteQuoteResponse-Rejected-Reason"></a>

### ExecuteQuoteResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_OTHER | 10 | The LP declines for a business reason not otherwise classified; t-0 persists details and routes the authorized payment to manual handling. |



<a name="tzero-v1-pay-lp-FiatSettlementSentResponse-Rejected-Reason"></a>

### FiatSettlementSentResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_EXECUTION_UNKNOWN | 10 | A listed execution was never created for this LP or has a durable Rejected result; do not settle it. |
| REASON_EXECUTION_ALREADY_COVERED | 20 | A listed execution is already covered by an accepted settlement. |
| REASON_CURRENCY_MISMATCH | 30 | local_currency does not match the covered executions' currency. |
| REASON_AMOUNT_MISMATCH | 40 | settlement_amount does not equal the covered executions' sum. |
| REASON_ACQUIRER_MIXED | 60 | The covered executions span more than one Acquirer (one transfer credits one account). |
| REASON_BANK_TRANSFER_REF_CONFLICT | 70 | bank_transfer_ref is already settled with different content; a genuinely different money movement is reported under a different reference. |



<a name="tzero-v1-pay-lp-PublishQuoteResponse-Failure-Reason"></a>

### PublishQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_VALIDITY_INVALID | 30 | A quote's expires_at is in the past, too short to be usable, or beyond the max window; the whole batch is declined. |


 <!-- end enums -->


