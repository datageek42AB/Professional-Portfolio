select c.*
, ca.* 
from ClientAccrual ca
join Client c on c.CLIENT_ID = ca.CLIENT_ID

/*--------------------------------------------------------
							JOIN
---------------------------------------------------------*/

select c.CLIENT_ID
, c.ClientName
, c.SERVICE_GROUP_ID
, ca.ACCRUAL_ID
, ca.AccrualName
, ca.AccrualDescription
from ClientAccrual ca
join Client c on c.CLIENT_ID = ca.CLIENT_ID

/*--------------------------------------------------------
						INNER JOIN
---------------------------------------------------------*/
select c.CLIENT_ID
, c.ClientName
, c.SERVICE_GROUP_ID
, ca.ACCRUAL_ID
, ca.AccrualName
, ca.AccrualDescription
from ClientAccrual ca
INNER JOIN Client c on c.CLIENT_ID = ca.CLIENT_ID

/*--------------------------------------------------------
				Can still use the where clause
---------------------------------------------------------*/
select c.CLIENT_ID
, c.ClientName
, c.SERVICE_GROUP_ID
, ca.ACCRUAL_ID
, ca.AccrualName
, ca.AccrualDescription
from ClientAccrual ca
INNER JOIN Client c on c.CLIENT_ID = ca.CLIENT_ID
where ca.AccrualName = 'PDO'
and ca.AccrualDescription = 'PDO'

/*--------------------------------------------------------
				Can join more than 1 table
---------------------------------------------------------*/
select c.CLIENT_ID
, c.ClientName
, c.SERVICE_GROUP_ID
, ssg.ServiceGroupName
, ca.ACCRUAL_ID
, ca.AccrualName
, ca.AccrualDescription
from ClientAccrual ca
INNER JOIN Client c on c.CLIENT_ID = ca.CLIENT_ID
INNER JOIN SecurityServiceGroup ssg on ssg.SERVICE_GROUP_ID = c.SERVICE_GROUP_ID
where ca.AccrualName = 'PDO'
and ca.AccrualDescription = 'PDO'

/*--------------------------------------------------------
						FULL JOIN (Need the right tables)
---------------------------------------------------------*/
select ccn.CONTACT_ID
, ccn.NOTIFICATION_TYPE_ID
, cc.CONTACT_ID
, cc.CLIENT_ID
, cc.Company
, cc.FirstName
, cc.LastName
from ClientContact cc
FULL JOIN ClientContactNotification ccn on ccn.CONTACT_ID = cc.CONTACT_ID


/*---------------------------------------------------
					Aggregates
---------------------------------------------------*/

-- Counts all rows in the table
select count(*) from ClientBenefit


-- Counts all rows where Benefit Title = Dental Pre-Tax 125
select count(*) as CountDentPreTaxClientRecs 
from ClientBenefit c 
where c.BenefitTitle = 'Dental Pre-Tax 125'


-- Sums the Actual Hours column for all records
Select sum(ca.ActualHours) as TotalActualHours
from CheckAccrual ca


-- Counts all rows where Benefit Title = Dental Pre-Tax 125 (or comment for all benefits)
-- Showing The Client ID associated with it**
Select top(100) cb.CLIENT_ID
, count(*) as CountofDentalPreTaxBenefits
from ClientBenefit cb
where cb.BenefitTitle = 'Dental Pre-Tax 125'
group by cb.CLIENT_ID