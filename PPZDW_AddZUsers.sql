--
-- If you download the users from your tenant, this will load that file and tag the 
-- txns in TxnFact with the tenant login, first name and last name.
--
.mode csv
create table zusers(UserID,UserName,FirstName,LastName,Status,WorkEmail,CreatedOn,ZuoraBillingRole,ZuoraPaymentRole,ZuoraCommerceRole,ZuoraPlatformRole,ZuoraFinanceRole,LastLogin);
.import AllUsersList.csv zusers
alter table TxnFact add column CreatedUserName;
alter table TxnFact add column UpdatedUserName;
update TxnFact set CreatedUserName = (select UserName from zusers where zusers.UserId = TxnFact.CreatedById);
update TxnFact set UpdatedUserName = (select UserName from zusers where zusers.UserId = TxnFact.UpdatedById);
