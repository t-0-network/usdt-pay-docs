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

<a name="tzero-v1-pay-LpCallbackService"></a>

## LpCallbackService
LP-implemented endpoint t-0 calls to request the LP's durable decision on a
standing quote execution for one authorized sale. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| ExecuteQuote | [ExecuteQuoteRequest](#tzero-v1-pay-ExecuteQuoteRequest) | [ExecuteQuoteResponse](#tzero-v1-pay-ExecuteQuoteResponse) | Requests a durable Accepted or Rejected result; only Accepted creates the LP's firm per-sale obligation. |


<a name="tzero-v1-pay-LpService"></a>

## LpService
t-0 endpoints the LP calls to push and withdraw standing quotes and to report
its self-initiated fiat settlements. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PublishQuote | [PublishQuoteRequest](#tzero-v1-pay-PublishQuoteRequest) | [PublishQuoteResponse](#tzero-v1-pay-PublishQuoteResponse) | Pushes immutable standing quotes into t-0's Order Book, at most one per currency per call; each is multi-consumable while it stands. |
| WithdrawQuote | [WithdrawQuoteRequest](#tzero-v1-pay-WithdrawQuoteRequest) | [WithdrawQuoteResponse](#tzero-v1-pay-WithdrawQuoteResponse) | Removes one standing quote before expiry; intents already accepted against it are unaffected. |
| FiatSettlementSent | [FiatSettlementSentRequest](#tzero-v1-pay-FiatSettlementSentRequest) | [FiatSettlementSentResponse](#tzero-v1-pay-FiatSettlementSentResponse) | Reports a fiat bank-rails settlement the LP made on its own initiative against accepted quote executions. An execution still awaiting its durable result returns FAILED_PRECONDITION; retry the same request. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-ExecuteQuoteRequest"></a>

### ExecuteQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| execution_id | [uint64](../scalar/#uint64) |  | t-0's id for this execution command; idempotency key and, after Accepted, the LP's obligation handle. |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote this execution is under. |
| quote_ref | [string](../scalar/#string) |  | LP's own identifier for that quote — a non-authoritative correlation echo. Lets the LP attribute the execution even when it arrives before the LP has recorded t-0's quote_id (publish-vs-execute race). |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's stable id for the Acquirer whose local-fiat obligation is being executed. |
| local_amount | [Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Fiat amount owed to the Acquirer for this sale, in the standing quote's currency. |
| amount_usdt | [Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | USDt the LP receives at settlement for this sale. |
| executed_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 created this durable execution command at authorization. |







<a name="tzero-v1-pay-ExecuteQuoteResponse"></a>

### ExecuteQuoteResponse
The LP's durable decision on one ExecuteQuote command.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [ExecuteQuoteResponse.Accepted](#tzero-v1-pay-ExecuteQuoteResponse-Accepted) |  | The LP accepts the execution. |
| rejected | [ExecuteQuoteResponse.Rejected](#tzero-v1-pay-ExecuteQuoteResponse-Rejected) |  | The LP declines the execution. |







<a name="tzero-v1-pay-ExecuteQuoteResponse-Accepted"></a>

### ExecuteQuoteResponse.Accepted
Acceptance creates the LP's firm per-sale obligation.


This message has no fields defined.






<a name="tzero-v1-pay-ExecuteQuoteResponse-Rejected"></a>

### ExecuteQuoteResponse.Rejected
Rejection leaves the payment intent authorized for manual handling.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [ExecuteQuoteResponse.Rejected.Reason](#tzero-v1-pay-ExecuteQuoteResponse-Rejected-Reason) |  | Stable business classification for declining the command. |
| details | [string](../scalar/#string) |  | Human-readable business details for declining the command. |







<a name="tzero-v1-pay-FiatSettlementSentRequest"></a>

### FiatSettlementSentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference on the bank-rails transfer; idempotency key, unique per LP. |
| settled_execution_ids | [uint64](../scalar/#uint64) | repeated | Accepted executions this settlement clears, treated as a set (duplicates collapse, order is not significant). |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency delivered; matches the covered executions' currency. |
| settlement_amount | [Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Local-fiat amount delivered; must equal the sum of the covered executions' local amounts. |
| settled_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the LP released the bank-rails transfer. |







<a name="tzero-v1-pay-FiatSettlementSentResponse"></a>

### FiatSettlementSentResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| accepted | [FiatSettlementSentResponse.Accepted](#tzero-v1-pay-FiatSettlementSentResponse-Accepted) |  |  |
| rejected | [FiatSettlementSentResponse.Rejected](#tzero-v1-pay-FiatSettlementSentResponse-Rejected) |  |  |







<a name="tzero-v1-pay-FiatSettlementSentResponse-Accepted"></a>

### FiatSettlementSentResponse.Accepted



This message has no fields defined.






<a name="tzero-v1-pay-FiatSettlementSentResponse-Rejected"></a>

### FiatSettlementSentResponse.Rejected



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [FiatSettlementSentResponse.Rejected.Reason](#tzero-v1-pay-FiatSettlementSentResponse-Rejected-Reason) |  |  |







<a name="tzero-v1-pay-PublishQuoteRequest"></a>

### PublishQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quotes | [PublishQuoteRequest.Quote](#tzero-v1-pay-PublishQuoteRequest-Quote) | repeated | Standing quotes to publish in one call, at most one per currency, each under its own quoteRef. The batch is atomic: one invalid quote declines the whole call and consumes no quoteRef. |







<a name="tzero-v1-pay-PublishQuoteRequest-Quote"></a>

### PublishQuoteRequest.Quote



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_ref | [string](../scalar/#string) |  | LP's identifier for this quote; idempotency key, unique per LP. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency the quote prices (e.g. COP). |
| fx_rate | [Decimal](../pay_common/#tzero-v1-pay-Decimal) |  | Published rate, in units of local_currency per 1 USDt. |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the quote stops standing, on t-0's clock. Validity bounds are a business decline (VALIDITY_INVALID), not request validation. |







<a name="tzero-v1-pay-PublishQuoteResponse"></a>

### PublishQuoteResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [PublishQuoteResponse.Success](#tzero-v1-pay-PublishQuoteResponse-Success) |  |  |
| failure | [PublishQuoteResponse.Failure](#tzero-v1-pay-PublishQuoteResponse-Failure) |  |  |







<a name="tzero-v1-pay-PublishQuoteResponse-Failure"></a>

### PublishQuoteResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [PublishQuoteResponse.Failure.Reason](#tzero-v1-pay-PublishQuoteResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-PublishQuoteResponse-Success"></a>

### PublishQuoteResponse.Success



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quotes | [PublishQuoteResponse.Success.PublishedQuote](#tzero-v1-pay-PublishQuoteResponse-Success-PublishedQuote) | repeated | One entry per published quote, in request order. |







<a name="tzero-v1-pay-PublishQuoteResponse-Success-PublishedQuote"></a>

### PublishQuoteResponse.Success.PublishedQuote



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_ref | [string](../scalar/#string) |  | Echo of the quote's quoteRef. |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote, used everywhere downstream. |







<a name="tzero-v1-pay-WithdrawQuoteRequest"></a>

### WithdrawQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_id | [uint64](../scalar/#uint64) |  | The standing quote to withdraw; must have been minted for this LP. |







<a name="tzero-v1-pay-WithdrawQuoteResponse"></a>

### WithdrawQuoteResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| success | [WithdrawQuoteResponse.Success](#tzero-v1-pay-WithdrawQuoteResponse-Success) |  |  |
| failure | [WithdrawQuoteResponse.Failure](#tzero-v1-pay-WithdrawQuoteResponse-Failure) |  |  |







<a name="tzero-v1-pay-WithdrawQuoteResponse-Failure"></a>

### WithdrawQuoteResponse.Failure



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| reason | [WithdrawQuoteResponse.Failure.Reason](#tzero-v1-pay-WithdrawQuoteResponse-Failure-Reason) |  |  |







<a name="tzero-v1-pay-WithdrawQuoteResponse-Success"></a>

### WithdrawQuoteResponse.Success



This message has no fields defined.





 <!-- end messages -->


<a name="tzero-v1-pay-ExecuteQuoteResponse-Rejected-Reason"></a>

### ExecuteQuoteResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_OTHER | 10 | The LP declines for a business reason not otherwise classified; t-0 persists details and routes the authorized payment to manual handling. |



<a name="tzero-v1-pay-FiatSettlementSentResponse-Rejected-Reason"></a>

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



<a name="tzero-v1-pay-PublishQuoteResponse-Failure-Reason"></a>

### PublishQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_VALIDITY_INVALID | 30 | A quote's expires_at is in the past, too short to be usable, or beyond the max window; the whole batch is declined. |



<a name="tzero-v1-pay-WithdrawQuoteResponse-Failure-Reason"></a>

### WithdrawQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_QUOTE_UNKNOWN | 10 | quote_id is unknown or belongs to another LP. |


 <!-- end enums -->


