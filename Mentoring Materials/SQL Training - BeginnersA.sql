/*---------------------------------------------------
					Query Basics
---------------------------------------------------*/
select top(100) * from Client 

select top(100) Client_ID
, ClientCode
, ClientName 
from Client


select top(100) *
from Client
where SERVICE_GROUP_ID = 2

select top(100) Client_ID
, ClientCode
, ClientName from Client
where SERVICE_GROUP_ID = 2


select top(100) * from Client
where SERVICE_GROUP_ID = 2
AND ClientName like '%Test%'


select top(100) * from ClientBenefit where BenefitTitle = 'Dental Pre-Tax 125'

/*---------------------------------------------------
						Nicknames
---------------------------------------------------*/
select top(100) c.Client_ID
, c.ClientCode
, c.ClientName 
from Client c
where c.SERVICE_GROUP_ID = 2


select top(100) Client.Client_ID
, ClientCode
, ClientName from Client 
where SERVICE_GROUP_ID = 2
AND ClientName like '%Test%'


/*---------------------------------------------------
					Sorting Records
---------------------------------------------------*/
-- See what's in the table first
Select top(100) * from ClientBenefit

select top(100) * 
from ClientBenefit cb
order by cb.DisplayOrder

select top(100) * 
from ClientBenefit cb 
order by cb.DisplayOrder desc

select top(100) * 
from ClientBenefit cb
order by cb.BenefitTitle, cb.DisplayOrder desc

/*---------------------------------------------------
					NULL Values
---------------------------------------------------*/
select * 
from ClientBenefit cb  -- Originally 4524 records (or 100)
where cb.WAIVE_MESSAGE_ID IS NULL  -- Returns 4510 records (or 100)

select *
from ClientBenefit cb
where cb.RELATED_BENEFIT_ID IS NOT NULL 

/*---------------------------------------------------
					And/Or Statements
---------------------------------------------------*/
-- Multiple AND Statements
select top(100) * 
from ClientBenefit cb 
where cb.BenefitTitle = 'Dental Pre-Tax 125'
and cb.DisplayOrder <> 0
and cb.RELATED_BENEFIT_ID IS NOT NULL


-- Multiple OR Statements
select top(100) * 
from ClientBenefit cb 
where cb.BenefitTitle = 'Dental Pre-Tax 125' 
OR cb.BenefitTitle = 'Medical Pre-Tax 125'
OR cb.DisplayOrder <> 0 
OR RELATED_BENEFIT_ID IS NOT NULL
order by cb.BenefitTitle, cb.DisplayOrder

-- Combined AND & OR Statements
select top(100) * 
from ClientBenefit cb 
where (cb.BenefitTitle = 'Dental Pre-Tax 125' OR cb.BenefitTitle = 'Medical Pre-Tax 125')
AND (cb.DisplayOrder <> 0 or RELATED_BENEFIT_ID IS NOT NULL)
order by cb.BenefitTitle, cb.DisplayOrder



