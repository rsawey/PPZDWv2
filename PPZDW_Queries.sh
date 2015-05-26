#!/bin/bash
# 
#  DS Queries aqua 
#  Using aqua pull all the data needed
#
#  Have to feed in the aqua URL stem (www or apisandbox), login, password, start date
#  and end date, date format is $STARTDATE and $ENDDATE.
#
#  richard.sawey@zuora.com
#
#  Written in bash, but only tested on a Mac running Mavericks, 10.9.5, your
#  mileage may vary
#
# 
BASE_URL=$1
USER_NAME=$2
PASSWORD=$3
STARTDATE=$4
ENDDATE=$5

echo 
echo "============= Posting the Aqua Job ===========" 
echo 
curl -i -k -u $USER_NAME:$PASSWORD -H "Content-Type:application/json" -H "Accept:application/json" -d '
{
"format" : "csv", 
"version" : "1.1", 
"name" : "PMZDW", 
"encrypted" : "none", 
"partner" : "", 
"project" : "", 
"queries" : [  { 
  "name" : "Invoice", 
  "query" : "select  Invoice.CreatedById, Invoice.CreatedDate, Invoice.UpdatedById, Invoice.UpdatedDate, Invoice.InvoiceNumber, Invoice.Amount, Invoice.Balance, Invoice.InvoiceDate, Account.AccountNumber as AccountNumber from Invoice where ( Invoice.Status='"'Posted'"' and (Invoice.InvoiceDate >= '"'$STARTDATE'"' and Invoice.InvoiceDate <= '"'$ENDDATE'"') )", 
  "type" : "zoqlexport" 
 },
{ 
  "name" : "Payment", 
  "query" : "select Payment.CreatedById, Payment.CreatedDate, Payment.UpdatedById, Payment.UpdatedDate, Payment.PaymentNumber, Payment.Amount, Payment.AppliedCreditBalanceAmount, Payment.EffectiveDate, Payment.Type, Account.AccountNumber as AccountNumber from Payment where (Payment.Status='"'Processed'"' and (Payment.EffectiveDate >= '"'$STARTDATE'"' and Payment.EffectiveDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
  },
 { 
  "name" : "InvoicePayment", 
  "query" : "select InvoicePayment.CreatedById, InvoicePayment.CreatedDate, InvoicePayment.UpdatedById, InvoicePayment.UpdatedDate, InvoicePayment.Amount, InvoicePayment.RefundAmount, Invoice.InvoiceNumber as InvoiceNumber, Payment.PaymentNumber as PaymentNumber from InvoicePayment where ( Payment.Status='"'Processed'"' and (Payment.EffectiveDate >= '"'$STARTDATE'"' and Payment.EffectiveDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
 },
  { 
  "name" : "InvoiceItemAdjustment", 
  "query" : "select InvoiceItemAdjustment.CreatedById, InvoiceItemAdjustment.CreatedDate, InvoiceItemAdjustment.UpdatedById, InvoiceItemAdjustment.UpdatedDate, InvoiceItemAdjustment.AdjustmentDate, InvoiceItemAdjustment.AdjustmentNumber, InvoiceItemAdjustment.Amount,  InvoiceItemAdjustment.InvoiceNumber, InvoiceItemAdjustment.SourceType, InvoiceItemAdjustment.Type, Account.AccountNumber as AccountNumber from InvoiceItemAdjustment where ( InvoiceItemAdjustment.Status='"'Processed'"' and (InvoiceItemAdjustment.AdjustmentDate >= '"'$STARTDATE'"' and InvoiceItemAdjustment.AdjustmentDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
  },
 {
  "name" : "InvoiceAdjustment", 
  "query" : "select InvoiceAdjustment.CreatedById, InvoiceAdjustment.CreatedDate, InvoiceAdjustment.UpdatedById, InvoiceAdjustment.UpdatedDate, InvoiceAdjustment.AdjustmentDate, InvoiceAdjustment.AdjustmentNumber, InvoiceAdjustment.Amount, InvoiceAdjustment.ImpactAmount, InvoiceAdjustment.InvoiceNumber, InvoiceAdjustment.Status, InvoiceAdjustment.Type, Account.AccountNumber as AccountNumber from InvoiceAdjustment where ( InvoiceAdjustment.Status ='"'Processed'"'  and (InvoiceAdjustment.AdjustmentDate >= '"'$STARTDATE'"' and InvoiceAdjustment.AdjustmentDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "CreditBalanceAdjustment", 
  "query" : "select CreditBalanceAdjustment.CreatedById, CreditBalanceAdjustment.CreatedDate, CreditBalanceAdjustment.UpdatedById, CreditBalanceAdjustment.UpdatedDate, CreditBalanceAdjustment.AdjustmentDate, CreditBalanceAdjustment.Amount, CreditBalanceAdjustment.Number, CreditBalanceAdjustment.SourceTransactionId, CreditBalanceAdjustment.SourceTransactionNumber, CreditBalanceAdjustment.SourceTransactionType, CreditBalanceAdjustment.Type, Account.AccountNumber as AccountNumber, Payment.PaymentNumber as PaymentNumber, Invoice.InvoiceNumber as InvoiceNumber, Refund.RefundNumber as RefundNumber from CreditBalanceAdjustment where ( CreditBalanceAdjustment.Status ='"'Processed'"' and (CreditBalanceAdjustment.AdjustmentDate >= '"'$STARTDATE'"' and CreditBalanceAdjustment.AdjustmentDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Account", 
  "query" : "select Account.CreatedById, Account.CreatedDate, Account.UpdatedById, Account.UpdatedDate, Account.Balance, Account.AccountNumber, Account.CreditBalance, Account.Currency, Account.Name from Account", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "RefundInvoicePayment", 
  "query" : "select RefundInvoicePayment.CreatedById, RefundInvoicePayment.CreatedDate, RefundInvoicePayment.UpdatedById, RefundInvoicePayment.UpdatedDate, RefundInvoicePayment.RefundAmount, Refund.RefundNumber as RefundNumber, Invoice.InvoiceNumber as InvoiceNumber, Payment.PaymentNumber as PaymentNumber, Account.AccountNumber as AccountNumber from RefundInvoicePayment where  (Refund.Status='"'Processed'"' and (Refund.RefundDate >= '"'$STARTDATE'"' and Refund.RefundDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Refund", 
  "query" : "select Refund.CreatedById, Refund.CreatedDate, Refund.UpdatedById, Refund.UpdatedDate, Refund.Amount, Refund.RefundDate, Refund.RefundNumber, Refund.Type, Account.AccountNumber as AccountNumber from Refund where (Refund.Status='"'Processed'"' and (Refund.RefundDate >= '"'$STARTDATE'"' and Refund.RefundDate <= '"'$ENDDATE'"'))", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "TaxationItem", 
  "query" : "select TaxationItem.AccountingCode, TaxationItem.CreatedById, TaxationItem.CreatedDate, TaxationItem.ExemptAmount, TaxationItem.Id, TaxationItem.Jurisdiction, TaxationItem.LocationCode, TaxationItem.Name, TaxationItem.TaxAmount, TaxationItem.TaxCode, TaxationItem.TaxCodeDescription, TaxationItem.TaxDate, TaxationItem.TaxMode, TaxationItem.TaxRate, TaxationItem.TaxRateDescription, TaxationItem.TaxRateType, TaxationItem.UpdatedById, TaxationItem.UpdatedDate, InvoiceItem.Id as InvoiceItemId, Invoice.Id as InvoiceId, Invoice.InvoiceNumber as InvoiceNumber from TaxationItem where ( Invoice.Status='"'Posted'"' and (Invoice.InvoiceDate >= '"'$STARTDATE'"' and Invoice.InvoiceDate <= '"'$ENDDATE'"') )", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "BillingRun", 
  "query" : "select BillingRun.BillingRunNumber, BillingRun.CreatedById, BillingRun.CreatedDate, BillingRun.EndDate, BillingRun.ErrorMessage, BillingRun.ExecutedDate, BillingRun.Id, BillingRun.InvoiceDate, BillingRun.NumberOfAccounts, BillingRun.NumberOfInvoices, BillingRun.StartDate, BillingRun.Status, BillingRun.TargetDate, BillingRun.TargetType, BillingRun.TotalTime, BillingRun.UpdatedById, BillingRun.UpdatedDate from BillingRun", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Usage", 
  "query" : "select Usage.AccountNumber, Usage.CreatedById, Usage.CreatedDate, Usage.EndDateTime, Usage.Id, Usage.Quantity, Usage.RbeStatus, Usage.SourceType, Usage.StartDateTime, Usage.SubmissionDateTime, Usage.UOM, Usage.UpdatedById, Usage.UpdatedDate from Usage", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "RatePlan", 
  "query" : "select RatePlan.AmendmentType, RatePlan.CreatedById, RatePlan.CreatedDate, RatePlan.Id, RatePlan.Name, RatePlan.UpdatedById, RatePlan.UpdatedDate, Subscription.Id as SubscriptionId, Account.Id as AccountId, Account.AccountNumber as AccountNumber from RatePlan", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "RatePlanCharge", 
  "query" : "select RatePlanCharge.AccountingCode, RatePlanCharge.ApplyDiscountTo, RatePlanCharge.BillCycleDay, RatePlanCharge.BillCycleType, RatePlanCharge.BillingPeriod, RatePlanCharge.BillingPeriodAlignment, RatePlanCharge.ChargeModel, RatePlanCharge.ChargeNumber, RatePlanCharge.ChargeType, RatePlanCharge.ChargedThroughDate, RatePlanCharge.CreatedById, RatePlanCharge.CreatedDate, RatePlanCharge.DMRC, RatePlanCharge.DTCV, RatePlanCharge.Description, RatePlanCharge.DiscountLevel, RatePlanCharge.EffectiveEndDate, RatePlanCharge.EffectiveStartDate, RatePlanCharge.Id, RatePlanCharge.IsLastSegment, RatePlanCharge.MRR, RatePlanCharge.Name, RatePlanCharge.NumberOfPeriods, RatePlanCharge.OriginalId, RatePlanCharge.OverageCalculationOption, RatePlanCharge.OverageUnusedUnitsCreditOption, RatePlanCharge.ProcessedThroughDate, RatePlanCharge.Quantity, RatePlanCharge.RevRecCode, RatePlanCharge.RevenueRecognitionRuleName, RatePlanCharge.RevRecTriggerCondition, RatePlanCharge.Segment, RatePlanCharge.SpecificBillingPeriod, RatePlanCharge.TCV, RatePlanCharge.TriggerDate, RatePlanCharge.TriggerEvent, RatePlanCharge.UOM, RatePlanCharge.UpToPeriods, RatePlanCharge.UpdatedById, RatePlanCharge.UpdatedDate, RatePlanCharge.Version, RatePlan.Id as RatePlanId, Subscription.Id as SubscriptionId, Account.Id as AccountId, Account.AccountNumber as AccountNumber from RatePlanCharge", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "RatePlanChargeTier", 
  "query" : "select RatePlanChargeTier.CreatedById, RatePlanChargeTier.CreatedDate, RatePlanChargeTier.Currency, RatePlanChargeTier.DiscountAmount, RatePlanChargeTier.DiscountPercentage, RatePlanChargeTier.EndingUnit, RatePlanChargeTier.Id, RatePlanChargeTier.IncludedUnits, RatePlanChargeTier.OveragePrice, RatePlanChargeTier.Price, RatePlanChargeTier.PriceFormat, RatePlanChargeTier.StartingUnit, RatePlanChargeTier.Tier, RatePlanChargeTier.UpdatedById, RatePlanChargeTier.UpdatedDate, RatePlanCharge.Id as RatePlanChargeId from RatePlanChargeTier", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Subscription", 
  "query" : "select Subscription.AutoRenew, Subscription.CancelledDate, Subscription.ContractAcceptanceDate, Subscription.ContractEffectiveDate, Subscription.CreatedById, Subscription.CreatedDate, Subscription.CreatorAccountId, Subscription.CreatorInvoiceOwnerId, Subscription.Id, Subscription.InitialTerm, Subscription.InvoiceOwnerId, Subscription.IsInvoiceSeparate, Subscription.Name, Subscription.Notes, Subscription.OriginalCreatedDate, Subscription.OriginalId, Subscription.PreviousSubscriptionId, Subscription.RenewalTerm, Subscription.ServiceActivationDate, Subscription.Status, Subscription.SubscriptionEndDate, Subscription.SubscriptionStartDate, Subscription.TermEndDate, Subscription.TermStartDate, Subscription.TermType, Subscription.UpdatedById, Subscription.UpdatedDate, Subscription.Version, Account.Id as AccountId, Account.AccountNumber as AccountNumber from Subscription", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Subscription", 
  "query" : "select SubscriptionVersionAmendment.AutoRenew, SubscriptionVersionAmendment.Code, SubscriptionVersionAmendment.ContractEffectiveDate, SubscriptionVersionAmendment.CreatedById, SubscriptionVersionAmendment.CreatedDate, SubscriptionVersionAmendment.CustomerAcceptanceDate, SubscriptionVersionAmendment.Description, SubscriptionVersionAmendment.EffectiveDate, SubscriptionVersionAmendment.Id, SubscriptionVersionAmendment.InitialTerm, SubscriptionVersionAmendment.Name, SubscriptionVersionAmendment.RenewalTerm, SubscriptionVersionAmendment.ServiceActivationDate, SubscriptionVersionAmendment.Status, SubscriptionVersionAmendment.SubscriptionId, SubscriptionVersionAmendment.TermStartDate, SubscriptionVersionAmendment.TermType, SubscriptionVersionAmendment.Type, SubscriptionVersionAmendment.UpdatedById, SubscriptionVersionAmendment.UpdatedDate, Account.Id as AccountId, Account.AccountNumber as AccountNumber from Subscription", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "Product", 
  "query" : "select Product.AllowFeatureChanges, Product.CreatedById, Product.CreatedDate, Product.Description, Product.EffectiveEndDate, Product.EffectiveStartDate, Product.Id, Product.Name, Product.SKU, Product.UpdatedById, Product.UpdatedDate from Product", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "ProductRatePlanCharge", 
  "query" : "select ProductRatePlan.CreatedById, ProductRatePlan.CreatedDate, ProductRatePlan.Description, ProductRatePlan.EffectiveEndDate, ProductRatePlan.EffectiveStartDate, ProductRatePlan.Id, ProductRatePlan.Name, ProductRatePlan.UpdatedById, ProductRatePlan.UpdatedDate,  ProductRatePlan.Id as ProductRatePlanId, Product.Id as ProductId, Product.SKU as ProductSKU from ProductRatePlanCharge", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "ProductRatePlanCharge", 
  "query" : "select ProductRatePlanCharge.AccountingCode, ProductRatePlanCharge.ApplyDiscountTo, ProductRatePlanCharge.BillCycleDay, ProductRatePlanCharge.BillCycleType, ProductRatePlanCharge.BillingPeriod, ProductRatePlanCharge.BillingPeriodAlignment, ProductRatePlanCharge.ChargeModel, ProductRatePlanCharge.ChargeType, ProductRatePlanCharge.CreatedById, ProductRatePlanCharge.CreatedDate, ProductRatePlanCharge.DefaultQuantity, ProductRatePlanCharge.DeferredRevenueAccount, ProductRatePlanCharge.Description, ProductRatePlanCharge.DiscountLevel, ProductRatePlanCharge.Id, ProductRatePlanCharge.IncludedUnits, ProductRatePlanCharge.LegacyRevenueReporting, ProductRatePlanCharge.MaxQuantity, ProductRatePlanCharge.MinQuantity, ProductRatePlanCharge.Name, ProductRatePlanCharge.NumberOfPeriod, ProductRatePlanCharge.OverageCalculationOption, ProductRatePlanCharge.OverageUnusedUnitsCreditOption, ProductRatePlanCharge.PriceChangeOption, ProductRatePlanCharge.PriceIncreasePercentage, ProductRatePlanCharge.RecognizedRevenueAccount, ProductRatePlanCharge.RevRecCode, ProductRatePlanCharge.RevenueRecognitionRuleName, ProductRatePlanCharge.RevRecTriggerCondition, ProductRatePlanCharge.SmoothingModel, ProductRatePlanCharge.SpecificBillingPeriod, ProductRatePlanCharge.TaxCode, ProductRatePlanCharge.TaxMode, ProductRatePlanCharge.Taxable, ProductRatePlanCharge.TriggerEvent, ProductRatePlanCharge.UOM, ProductRatePlanCharge.UpToPeriods, ProductRatePlanCharge.UpdatedById, ProductRatePlanCharge.UpdatedDate, ProductRatePlanCharge.UseDiscountSpecificAccountingCode, ProductRatePlanCharge.UseTenantDefaultForPriceChange, Product.Id as ProductId, Product.SKU as ProductSKU from ProductRatePlanCharge", 
  "type" : "zoqlexport" 
 },
 { 
  "name" : "ProductRatePlanChargeTier", 
  "query" : "select ProductRatePlanChargeTier.Active, ProductRatePlanChargeTier.CreatedById, ProductRatePlanChargeTier.CreatedDate, ProductRatePlanChargeTier.Currency, ProductRatePlanChargeTier.DiscountAmount, ProductRatePlanChargeTier.DiscountPercentage, ProductRatePlanChargeTier.EndingUnit, ProductRatePlanChargeTier.Id, ProductRatePlanChargeTier.IncludedUnits, ProductRatePlanChargeTier.OveragePrice, ProductRatePlanChargeTier.Price, ProductRatePlanChargeTier.PriceFormat, ProductRatePlanChargeTier.StartingUnit, ProductRatePlanChargeTier.Tier, ProductRatePlanChargeTier.UpdatedById, ProductRatePlanChargeTier.UpdatedDate, ProductRatePlanCharge.Id as ProductRatePlanChargeId from ProductRatePlanChargeTier", 
  "type" : "zoqlexport" 
  } ,
   { 
  "name" : "Contact", 
  "query" : "select Contact.AccountId, Contact.Address1, Contact.Address2, Contact.City, Contact.Country, Contact.County, Contact.CreatedById, Contact.CreatedDate, Contact.Description, Contact.Fax, Contact.FirstName, Contact.HomePhone, Contact.Id, Contact.LastName, Contact.MobilePhone, Contact.NickName, Contact.OtherPhone, Contact.OtherPhoneType, Contact.PersonalEmail, Contact.PostalCode, Contact.State, Contact.TaxRegion, Contact.UpdatedById, Contact.UpdatedDate, Contact.WorkEmail, Contact.WorkPhone, Account.Id as AccountId, Account.AccountNumber as AccountNumber from Contact", 
  "type" : "zoqlexport" 
  } 
 ] 
} 
 ' -X POST https://$BASE_URL.zuora.com/apps/api/batch-query/
 echo
