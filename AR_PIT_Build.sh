#!/bin/bash
# 
#  AR-PIT - AR Point In Time Database and Reporting
# 
# Load up on more SQL to build out the database
#
# This script will build a TxnFact table of TRANSACTIONS only, not create accounts
# or new subscriptions or ammendments and their MRR and TCV.
#
#
DBFILE="PPZDW_Data.sqlite"
if [ ! $# > 1 ]; then
  echo "Usage: \.\/AR_PUT_Build.sh DatabaseFileName [optional]"
  exit
fi

#  Let's open and start building our new database build file
ARBUILDFILE=AR_PIT_Data.sql

cat <<EOT > $ARBUILDFILE
create index Account_Num on Account(AccountNumber);
create index Payment_Num on Payment(PaymentNumber);
create index Refund_Num on Refund(RefundNumber);
create index CBA_Num on CreditBalanceAdjustment(Number);
create index IIA_Num on InvoiceItemAdjustment(AdjustmentNumber);
create index IA_Num on InvoiceAdjustment(AdjustmentNumber);

create table TxnFact (Id INTEGER PRIMARY KEY AUTOINCREMENT, AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, AcctBalance, AcctCreditBalance, CreatedDate, CreatedById, UpdatedDate, UpdatedById);
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'Invoice', InvoiceNumber,InvoiceDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from Invoice;
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'Payment', PaymentNumber,EffectiveDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from Payment;
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'Refund', RefundNumber,RefundDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from Refund;
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'IIA Credit', AdjustmentNumber,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from InvoiceItemAdjustment where Type='Credit';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'IIA Charge', AdjustmentNumber,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from InvoiceItemAdjustment where Type='Charge';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'IA Credit', AdjustmentNumber,AdjustmentDate,ImpactAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from InvoiceAdjustment where Type='Credit';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'IA Charge', AdjustmentNumber,AdjustmentDate,ImpactAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from InvoiceAdjustment where Type='Charge';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'CBA Increase - Invoice', Number,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from CreditBalanceAdjustment where SourceTransactionType='Invoice' and Type='Increase';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'CBA Decrease - Invoice', Number,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from CreditBalanceAdjustment where SourceTransactionType='Invoice' and Type='Decrease';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'CBA Increase - Payment', Number,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from CreditBalanceAdjustment where SourceTransactionType='Payment' and Type='Increase';
insert into TxnFact (AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount, CreatedDate, CreatedById, UpdatedDate, UpdatedById) select AccountNumber,'CBA Decrease - Refund', Number,AdjustmentDate,Amount, CreatedDate, CreatedById, UpdatedDate, UpdatedById from CreditBalanceAdjustment where SourceTransactionType='Refund';

create index TxnFact_AccNumber on TxnFact(AccountNumber);

create view TxnLog as select Id, AccountNumber,TxnType,TxnNumber,TxnDate,TxnAmount
	from TxnFact order by AccountNumber, TxnDate;
EOT

sqlite3 $DBFILE < $ARBUILDFILE
