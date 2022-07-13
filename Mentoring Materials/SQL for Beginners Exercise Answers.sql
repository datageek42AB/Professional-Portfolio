/*  1.	Write a query to show the Benefit Coverage ID, Coverage Code, Minimum Dependents
	    , and Maximum Dependents from the SystemBenefitCoverage table.
*/

select BENEFIT_COVERAGE_ID
, CoverageCode
, MinimumDependants
, MaximumDependants 
from SystemBenefitCoverage

/*  2.	Show the same columns from the SystemBenefitCoverage table only for records that 
		have NULL values for Minimum OR Maximum dependents.
*/

select BENEFIT_COVERAGE_ID
, CoverageCode
, MinimumDependants
, MaximumDependants 
from SystemBenefitCoverage
where MinimumDependants IS NULL
or MaximumDependants IS NULL

/*	3.	Show the same columns from the SystemBenefitCoverage table only for records that 
		have NULL values for BOTH Minimum AND Maximum dependents.
*/
select BENEFIT_COVERAGE_ID
, CoverageCode
, MinimumDependants
, MaximumDependants 
from SystemBenefitCoverage
where MinimumDependants IS NULL
AND MaximumDependants IS NULL

/*	4.	Write a query that returns all records from the SystemBenefitPlan table with ‘DM’ 
		somewhere within the PlanDescription field.
*/

select *
from SystemBenefitPlan
where PlanDescription like '%DM%'


/*	5.	Write a query that returns all records from the SystemBenefitPlan table with a 
		StartDate >= 04/01/2019.
*/

select *
from SystemBenefitPlan
where StartDate >= '04/01/2019' 

/*	6.	What is the total count of SystemBenefitPlans with a Primary Care Physician Allowed?
*/
select count(*) as Plans
from SystemBenefitPlan 
where IsPrimaryCarePhysicianAllowed = 1

/*	7.	What is the total count of SystemBenefitPlans with a Primary Care Physician Allowed 
		BUT not Required?
*/

select count(*) as Plans
from SystemBenefitPlan 
where IsPrimaryCarePhysicianAllowed = 1
and IsPrimaryCarePhysicianRequired = 0

/*	8.	Write a query that returns the AccountDescription, and the Average Amount for 
		Checking and Savings accounts from the EmployeeDirectDepositHistory table
*/

select AccountDescription
, AVG(Amount) as AverageAmount
from EmployeeDirectDepositHistory
where AccountDescription = 'Checking' or AccountDescription = 'Savings'
group by AccountDescription
