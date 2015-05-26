/*  CREATE TABLE RatePlanCharge(
AccountingCode,ApplyDiscountTo,
BillCycleDay,BillCycleType,BillingPeriod,BillingPeriodAlignment,
ChargeModel,ChargeNumber,ChargeType,ChargedThroughDate,CreatedByID,CreatedDate,
DMRC,DTCV,Description,DiscountLevel,EffectiveEndDate,EffectiveStartDate,
ID,IsLastSegment,MRR,Name,NumberofPeriods,OriginalID,OverageCalculationOption,OverageUnusedUnitsCreditOption,
ProcessedThroughDate,Quantity,RevenueRecognitionCode,RevenueRecognitionRuleName,RevenueRecognitionTriggerCondition,
Segment,SpecificBillingPeriod,TCV,TriggerDate,TriggerEvent,UnitofMeasure,UpToPeriods,UpdatedByID,UpdatedDate,Version,RatePlanId,SubscriptionId,AccountId,AccountNumber);
*/

select count(*) from RatePlanCharge;

select count(*)
from RatePlanCharge rpc, Account a, Subscription s, RatePlan rp
where rpc.RatePlanId = rp.Id
and rpc.AccountNumber = a.AccountNumber
and rpc.SubscriptionId  = s.Id
;

select a.AccountNumber, s.Name, rp.Name, rpc.ChargeNumber, rpc.Name, rpc.MRR, rpc.TCV, rpc.Version, rpc.EffectiveStartDate, rpc.EffectiveEndDate, rpc.Segment, s.Version
from RatePlanCharge rpc, Account a, Subscription s, RatePlan rp
where rpc.RatePlanId = rp.Id
and rpc.AccountNumber = a.AccountNumber
and rpc.SubscriptionId  = s.Id
and (s.Status = 'Active' or s.Status = 'Cancelled')
order by a.AccountNumber, s.Name, s.Version, rpc.ChargeNumber, rpc.Segment
;
