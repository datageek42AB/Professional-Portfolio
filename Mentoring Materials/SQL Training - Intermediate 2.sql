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