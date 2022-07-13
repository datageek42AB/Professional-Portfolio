select distinct
  SUBSTRING(s.SuitePath, PATINDEX('%Year End 2019\%', s.SuitePath), ( CHARINDEX('\', (SUBSTRING(s.SuitePath, PATINDEX('%Year End 2019\%', s.SuitePath), 50)))-1)) as PrimaryFolder
, CASE
	when s.SuiteName like '%PEO%' then 'PEO'
	when s.SuiteName like '%ACA%' then 'ACA'
	when s.SuiteName like '%Employee Management%' then 'Employee Management' 
	when s.SuiteName like '%Employee Self Service%' then 'Employee Self Service' 
	when s.SuiteName like '%Client Management%' then 'Client Management'
	when s.SuiteName like '%Payroll Processing%' then 'Payroll Processing'
	when s.SuiteName like '%Reporting%' then 'Reporting'
	when s.SuiteName like '%Conversion Management%' then 'Conversion Management'
	when s.SuiteName like '%Customer Service%' then 'Customer Service'
	when s.SuiteName like '%System Management%' then 'System Management'
	when s.SuiteName like '%Production Utilities%' then 'Production Utilites'
	when s.SuiteName like '%Print Utilities%' then 'Print Utilities'
	when s.SuiteName like '%On-Site Print Testing%' then 'Print Testing'
	when s.SuiteName like '%EFW2%' then 'EFW2'
	when s.SuiteName like '%Pass Validation%' or s.Suitename like '%Pass Setup%' then 'W2 & 1099s'	 
	End as FunctionalArea
, latestrun.ExecutionComplete as ExecutionComplete
, latestrun.TestRunId
, ftr.TestCaseId
, dtr.Outcome
, p.Name as TestedBy
from FactTestResult ftr
join CurrentWorkItemView wi on wi.System_Id = ftr.TestCaseId 
		and wi.Infinisource_VSTS_Regression = 1
join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
	and s.SuitePath like '%Year End 2019%\%'
left join DimTestRun run1 on ftr.TestRunSK = run1.TestRunSK
left join DimPerson p on p.PersonSK = run1.RunOwnerSK
join 
	(select ftr.TestCaseId
	, RIGHT(LEFT(SUBSTRING(s.SuitePath, PATINDEX('%Year End 2019\%', s.SuitePath), 50), 33), 21) as TestIteration
	, max(dtr.DateCompleted) as ExecutionComplete
	, max(r.TestRunId) as TestRunId
	, max(r.TestRunSK) as TestRunSK
	from DimTestRun r
	join FactTestResult ftr on ftr.TestRunSK = r.TestRunSK 
	join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
	join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
		and s.SuitePath like '%Year End 2019%\%'
	group by ftr.TestCaseId, s.SuitePath
	) latestrun 
		on latestrun.TestRunID = run1.TestRunId

union

select distinct
  SUBSTRING(s.SuitePath, PATINDEX('%Year End 2019\%', s.SuitePath), ( CHARINDEX('\', (SUBSTRING(s.SuitePath, PATINDEX('%Year End 2019\%', s.SuitePath), 50)))-1)) as PrimaryFolder
, CASE
	when s.SuiteName like '%PEO%' then 'PEO'
	when s.SuiteName like '%ACA%' then 'ACA'
	when s.SuiteName like '%Employee Management%' then 'Employee Management' 
	when s.SuiteName like '%Employee Self Service%' then 'Employee Self Service' 
	when s.SuiteName like '%Client Management%' then 'Client Management'
	when s.SuiteName like '%Payroll Processing%' then 'Payroll Processing'
	when s.SuiteName like '%Reporting%' then 'Reporting'
	when s.SuiteName like '%Conversion Management%' then 'Conversion Management'
	when s.SuiteName like '%Customer Service%' then 'Customer Service'
	when s.SuiteName like '%System Management%' then 'System Management'
	when s.SuiteName like '%Production Utilities%' then 'Production Utilites'
	when s.SuiteName like '%Print Utilities%' then 'Print Utilities'
	when s.SuiteName like '%On-Site Print Testing%' then 'Print Testing'
	when s.SuiteName like '%EFW2%' then 'EFW2'
	when s.SuiteName like '%Pass Validation%' or s.Suitename like '%Pass Setup%' then 'W2 & 1099s'	 
	End as FunctionalArea
, NULL as ExecutionComplete
, run1.TestRunId
, ftr.TestCaseId
, dtr.Outcome
, p.name as TestedBy
from FactTestResult ftr
join CurrentWorkItemView wi on wi.System_Id = ftr.TestCaseId 
join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
	and s.SuitePath like '%Year End 2019%\%'
left join DimTestRun run1 on ftr.TestRunSK = run1.TestRunSK
left join DimPerson p on p.PersonSK = run1.RunOwnerSK
where dtr.Outcome = 'Never Run'