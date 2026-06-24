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
LP-implemented endpoint t-0 calls to bind the LP to a standing quote's locked
rate for one authorized sale. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| ExecuteQuote | [ExecuteQuoteRequest](#tzero-v1-pay-ExecuteQuoteRequest) | [ExecuteQuoteResponse](#tzero-v1-pay-ExecuteQuoteResponse) | Creates the LP's firm per-sale obligation at the standing quote's locked rate. |


<a name="tzero-v1-pay-LpService"></a>

## LpService
t-0 endpoints the LP calls to push and withdraw standing quotes and to report
its self-initiated fiat settlements. Fiat mode only.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| PublishQuote | [PublishQuoteRequest](#tzero-v1-pay-PublishQuoteRequest) | [PublishQuoteResponse](#tzero-v1-pay-PublishQuoteResponse) | Pushes one immutable standing quote into t-0's Order Book; multi-consumable while it stands. |
| WithdrawQuote | [WithdrawQuoteRequest](#tzero-v1-pay-WithdrawQuoteRequest) | [WithdrawQuoteResponse](#tzero-v1-pay-WithdrawQuoteResponse) | Removes one standing quote before expiry; intents already accepted against it are unaffected. |
| FiatSettlementSent | [FiatSettlementSentRequest](#tzero-v1-pay-FiatSettlementSentRequest) | [FiatSettlementSentResponse](#tzero-v1-pay-FiatSettlementSentResponse) | Reports a fiat bank-rails settlement the LP made on its own initiative against locked executions. |

 <!-- end services -->


##  Requests And Response Types


<a name="tzero-v1-pay-ExecuteQuoteRequest"></a>

### ExecuteQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| execution_id | [uint64](../scalar/#uint64) |  | t-0's id for this execution; idempotency key and the LP's obligation handle. |
| quote_id | [uint64](../scalar/#uint64) |  | t-0's id for the standing quote this execution is under. |
| quote_ref | [string](../scalar/#string) |  | LP's own identifier for that quote — a non-authoritative correlation echo. Lets the LP attribute the execution even when it arrives before the LP has recorded t-0's quote_id (publish-vs-execute race). |
| acquirer_id | [uint64](../scalar/#uint64) |  | t-0's stable id for the Acquirer; the LP resolves the registered bank destination from it. |
| local_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Fiat amount owed to the Acquirer for this sale, in the standing quote's currency. |
| amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | USDt the LP receives at settlement for this sale. |
| executed_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment t-0 bound the LP to this execution. |







<a name="tzero-v1-pay-ExecuteQuoteResponse"></a>

### ExecuteQuoteResponse



This message has no fields defined.






<a name="tzero-v1-pay-FiatSettlementSentRequest"></a>

### FiatSettlementSentRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| bank_transfer_ref | [string](../scalar/#string) |  | Reference on the bank-rails transfer; idempotency key, unique per LP. |
| settled_execution_ids | [uint64](../scalar/#uint64) | repeated | Executions this settlement clears, in the LP's execution-space. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency delivered; matches the covered executions' currency. |
| settlement_amount | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Local-fiat amount delivered; must equal the sum of the covered executions' local amounts. |
| destination_account | [string](../scalar/#string) |  | Acquirer's registered bank destination the fiat was sent to. |
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
| failing_execution_ids | [uint64](../scalar/#uint64) | repeated | Executions that failed validation against t-0's ledger. |







<a name="tzero-v1-pay-PublishQuoteRequest"></a>

### PublishQuoteRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| quote_ref | [string](../scalar/#string) |  | LP's identifier for this quote; idempotency key, unique per LP. |
| local_currency | [string](../scalar/#string) |  | ISO 4217 currency the quote prices (e.g. COP). |
| fx_rate | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Rate committed, in units of local_currency per 1 USDt. |
| min_amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Smallest single sale this quote may price, in USDt (domain rule: at least 0.01). |
| max_amount_usdt | [tzero.v1.common.Decimal](../common_common/#tzero-v1-common-Decimal) |  | Largest single sale this quote may price, in USDt (domain rule: at least min_amount_usdt). |
| expires_at | [google.protobuf.Timestamp](../scalar/#google-protobuf-Timestamp) |  | Moment the quote stops standing, on t-0's clock. |







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


<a name="tzero-v1-pay-FiatSettlementSentResponse-Rejected-Reason"></a>

### FiatSettlementSentResponse.Rejected.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_EXECUTION_UNKNOWN | 10 | A listed execution was never created for this LP. |
| REASON_EXECUTION_ALREADY_COVERED | 20 | A listed execution is already covered by an accepted settlement. |
| REASON_CURRENCY_MISMATCH | 30 | local_currency does not match the covered executions' currency. |
| REASON_AMOUNT_MISMATCH | 40 | settlement_amount does not equal the covered executions' sum. |
| REASON_DESTINATION_MISMATCH | 50 | destination_account is not the Acquirer's registered bank destination. |
| REASON_ACQUIRER_MIXED | 60 | The covered executions span more than one Acquirer (one transfer credits one account). |



<a name="tzero-v1-pay-PublishQuoteResponse-Failure-Reason"></a>

### PublishQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_CURRENCY_UNSUPPORTED | 10 | The quote's currency is not supported. |
| REASON_LIMITS_INVALID | 20 | min/max bounds are not well-formed. |
| REASON_VALIDITY_INVALID | 30 | expires_at is in the past, too short to be usable, or beyond the max window. |



<a name="tzero-v1-pay-WithdrawQuoteResponse-Failure-Reason"></a>

### WithdrawQuoteResponse.Failure.Reason


| Name | Number | Description |
| ---- | ------ | ----------- |
| REASON_UNSPECIFIED | 0 |  |
| REASON_QUOTE_UNKNOWN | 10 | quote_id is unknown or belongs to another LP. |


 <!-- end enums -->


