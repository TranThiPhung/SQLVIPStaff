declare @card varchar(30)= '0935783385'
declare @cust varchar(20)= 'K000029091'
declare @currrent datetime 
set @currrent = getdate() -- thoi diem tinh toann mui gio VN
set @currrent = '2023-04-26 17:17:00 '
declare @seconds bigint =DATEDIFF(SECOND, CONVERT(DATE,@currrent),@currrent)
--select @seconds
declare @fromdatetime datetime,@todatetime datetime
declare @fromdate date = convert(date,DATEADD(DAY, -365, @currrent))
declare @todate date= convert(date, @currrent)
set @fromdatetime =dateadd(hour,-7,  DATEADD(day,-365, @currrent))

set @todatetime= DATEADD(hour,-7,@currrent)
SELECT isnull(sum(AmountToAccount),0) as POS
FROM RetailTransactionTable
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND RetailTransactionTable.entryStatus != 1
  AND RetailTransactionTable.loyaltyCardId = @card
  AND RetailTransactionTable.custAccount = @cust
  AND RetailTransactionTable.type = 2 and((RetailTransactionTable.transDate >@fromdate)
                                           OR (RetailTransactionTable.transDate = @fromdate
                                               AND RetailTransactionTable.transTime>=@seconds))
                                          AND (RetailTransactionTable.transDate <@todate
                                               OR (RetailTransactionTable.transDate = @fromdate
                                                   AND RetailTransactionTable.transTime<=@seconds)) 

SELECT isnull(sum(AmountTendered),0)*-1 as Extracare
FROM RetailTransactionPaymentTrans
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND tenderType = '2'
  AND loyaltyCardId = @card
  AND transactionStatus != 1 
  and(transDate >@fromdate OR (transDate = @fromdate AND transTime>=@seconds))
 AND (transDate <@todate OR (transDate = @todate AND transTime<=@seconds))
 
 SELECT isnull(sum(AdjustmentAmount),0) as Adjust
FROM PmcRetailLoyaltyCardAmountAdjustment
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND PmcRetailLoyaltyCardAmountAdjustment.CardNumber = @card
  AND PmcRetailLoyaltyCardAmountAdjustment.NgayTao>=@fromdate
  AND PmcRetailLoyaltyCardAmountAdjustment.NgayTao<=@todate
  AND (PmcRetailLoyaltyCardAmountAdjustment.Description not like'Evaluation tier card yearly')
  AND (PmcRetailLoyaltyCardAmountAdjustment.Description not like 'Evaluation tier Employee')

  select isnull(sum(InvoiceAmount),0) as Ecomer from custInvoiceJour
            where custInvoiceJour.InvoiceAccount = @cust
           and PARTITION = 5637144576
  AND DATAAREAID='phct'
        and exists (select 1 from salesTable
            where SalesTable.CustAccount        = @cust
			and PARTITION = 5637144576
  AND DATAAREAID='phct'
                and SalesTable.SalesId           = custInvoiceJour.SalesId
                and SalesTable.VtvEcommerce      = 1
                and SalesTable.SalesStatus       = 3--SalesStatus::Invoiced
                and salesTable.createdDateTime<= @todatetime
                and salesTable.createdDateTime >=@fromdatetime)
/*select sum(amount)/1000000.0 as [Total amount (Trieu VND)] from

(
SELECT isnull(sum(AmountToAccount),0) as Amount
FROM RetailTransactionTable
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND RetailTransactionTable.entryStatus != 1
  AND RetailTransactionTable.loyaltyCardId = @card
  AND RetailTransactionTable.custAccount = @cust
  AND RetailTransactionTable.type = 2 and((RetailTransactionTable.transDate >@fromdate)
                                           OR (RetailTransactionTable.transDate = @fromdate
                                               AND RetailTransactionTable.transTime>=@seconds))
                                          AND (RetailTransactionTable.transDate <@todate
                                               OR (RetailTransactionTable.transDate = @fromdate
                                                   AND RetailTransactionTable.transTime<=@seconds))
union all

SELECT isnull(sum(AmountTendered),0)*-1 as Amount
FROM RetailTransactionPaymentTrans
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND tenderType = '2'
  AND loyaltyCardId = @card
  AND transactionStatus != 1 
  and(transDate >@fromdate OR (transDate = @fromdate AND transTime>=@seconds))
 AND (transDate <@todate OR (transDate = @todate AND transTime<=@seconds))
 
 union all
SELECT isnull(sum(AdjustmentAmount),0) as Amount
FROM PmcRetailLoyaltyCardAmountAdjustment
WHERE PARTITION = 5637144576
  AND DATAAREAID='phct'
  AND PmcRetailLoyaltyCardAmountAdjustment.CardNumber = @card
  AND PmcRetailLoyaltyCardAmountAdjustment.NgayTao>=@fromdate
  AND PmcRetailLoyaltyCardAmountAdjustment.NgayTao<=@todate
  AND (PmcRetailLoyaltyCardAmountAdjustment.Description not like'Evaluation tier card yearly')
  AND (PmcRetailLoyaltyCardAmountAdjustment.Description not like 'Evaluation tier Employee')
  
  union all
     select isnull(sum(InvoiceAmount),0) as Amount from custInvoiceJour
            where custInvoiceJour.InvoiceAccount = @cust
           and PARTITION = 5637144576
  AND DATAAREAID='phct'
        and exists (select 1 from salesTable
            where SalesTable.CustAccount        = @cust
			and PARTITION = 5637144576
  AND DATAAREAID='phct'
                and SalesTable.SalesId           = custInvoiceJour.SalesId
                and SalesTable.VtvEcommerce      = 1
                and SalesTable.SalesStatus       = 3--SalesStatus::Invoiced
                and salesTable.createdDateTime<= @todatetime
                and salesTable.createdDateTime >=@fromdatetime)
)X*/