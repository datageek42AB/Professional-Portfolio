select distinct
  SUBSTRING(s.SuitePath, PATINDEX('%Smoke Test_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%', s.SuitePath), ( CHARINDEX('\', (SUBSTRING(s.SuitePath, PATINDEX('%Smoke Test_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%', s.SuitePath), 50)))-1)) as Sstring
, s.SuiteName as Environment
, SUBSTRING(s.SuitePath, PATINDEX('%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10) as SmokeTestDate
, run.TestRunId
, ftr.TestCaseId
, dtr.Outcome
, run.CompleteDate
from FactTestResult ftr
join CurrentWorkItemView wi on wi.System_Id = ftr.TestCaseId 
		and wi.System_Title like '%Smoke Test%'
join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
	and s.SuitePath like '%Smoke Tests\Smoke Test%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%'
	and CAST(REPLACE(SUBSTRING(s.SuitePath, PATINDEX('%20[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10), '_', '') AS DATETIME) >= GETDATE()-29
	and CAST(REPLACE(SUBSTRING(s.SuitePath, PATINDEX('%20[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10), '_', '') AS DATETIME) >= '2019-07-30'
left join DimTestRun run1 on ftr.TestRunSK = run1.TestRunSK
join 
	(select ftr.TestCaseId
	, RIGHT(LEFT(SUBSTRING(s.SuitePath, PATINDEX('%Smoke Tests\%', s.SuitePath), 50), 33), 21) as TestIteration
	, SUBSTRING(s.SuitePath, PATINDEX('%20[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10) as SmokeTestDate
	, max(r.TestRunId) as TestRunId
	, max(r.TestRunSK) as TestRunSK
	, max(r.CompleteDate) as CompleteDate
	from DimTestRun r
	join FactTestResult ftr on ftr.TestRunSK = r.TestRunSK 
	join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
	join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
		and s.SuitePath like '%Smoke Tests\Smoke Test%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%'
	group by ftr.TestCaseId, s.SuitePath
	) run 
		on run.TestRunID = run1.TestRunId
group by s.SuitePath, s.SuiteName, dtr.Outcome, run.TestRunId, ftr.TestCaseId, run.CompleteDate

union all

select distinct
  SUBSTRING(s.SuitePath, PATINDEX('%Smoke Test_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%', s.SuitePath), ( CHARINDEX('\', (SUBSTRING(s.SuitePath, PATINDEX('%Smoke Test_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%', s.SuitePath), 50)))-1)) as Sstring
, s.SuiteName as Environment
, SUBSTRING(s.SuitePath, PATINDEX('%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10) as SmokeTestDate
, run.TestRunId
, ftr.TestCaseId
, dtr.Outcome
, run.CompleteDate
from FactTestResult ftr
join CurrentWorkItemView wi on wi.System_Id = ftr.TestCaseId 
		and wi.System_Title like '%Smoke Test%'
join DimTestResult dtr on dtr.ResultSK = ftr.ResultSK
left join DimTestRun run on run.TestRunSK = ftr.TestRunSK
join DimTestSuite s on s.TestSuiteSK = ftr.TestSuiteSK
where s.SuitePath like '%Smoke Tests\Smoke Test%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%\%'
	and dtr.Outcome = 'Never Run'
	and CAST(REPLACE(SUBSTRING(s.SuitePath, PATINDEX('%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10), '_', '') AS DATETIME) >= '2019-07-30'
	and CAST(REPLACE(SUBSTRING(s.SuitePath, PATINDEX('%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', s.SuitePath),10), '_', '') AS DATETIME) >= GETDATE()-29



