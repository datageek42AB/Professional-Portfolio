Drop table #WIs

select wi.System_Id as TFS_ID
, wi.WorkItemSK
, wi.System_WorkItemType as Work_Item_Type
, wi.System_Title as Title
, CASE
	when wi.IterationPath like '%Custom Reports%' then 'Custom Reports'
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
    when wi.AreaPath like '%CompanyX View%' then 'CompanyX View'
	when wi.areaPath like '%Tax Forms%' then 'Tax Forms'
	when wi.AreaPath like '%Custom Report%' then 'Custom Reporting'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Infrastructure%' then 'Infrastructure'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%Migration%' then 'Migration'
	when wi.AreaPath like '%Local Print%' then 'Local Print'
	when wi.AreaPath like '%Engage%' then 'Mojo'
	when wi.AreaPath like '%Mobile%' then 'Mobile'
	when wi.AreaPath like '%Time%' then 'Time'
	when (wi.AreaPath like '%NXGG2%' or wi.AreaPath like '%CompanyX Touch%') then 'Timeclocks'
	when wi.AreaPath like '%Tax%' then 'Tax'
	when wi.AreaPath like '%TFII - ISTF%' then 'Timeforce II'
	when wi.AreaPath like '%CompanyX QA Automation' then 'QA Automation'
	else 'Other' 
	end as Program_Area
, wi.IterationPath as Iteration_Closed
, wi.System_CreatedDate as Created_Date
, wi.Microsoft_VSTS_Common_ClosedDate as Closed_Date 
, wi.AOS_VSTS_HotfixVersion
into #WIs
from CurrentWorkItemView wi
where wi.System_WorkItemType in ('Bug', 'Product Backlog Item')
and wi.System_State = 'Closed'
and wi.System_Reason not in ('Obsolete', 'Duplicate', 'As Designed', 'Unable to Reproduce', 'Deferred', 'Cut')
and wi.System_IsDeleted = 0
and wi.Microsoft_VSTS_Common_ClosedDate >= '2018-09-01'
and (wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14'
	OR (wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-01' 
		and (wi.NAME_VSTS_EnvironmentFoundIn <> 'RCQA' or wi.System_Title not like '%QAB%')
		and wi.AOS_VSTS_HotfixVersion IS NOT NULL
		and wi.AOS_VSTS_HotfixVersion < '6.2' or (wi.AOS_VSTS_HotfixVersion IS NOT NULL and wi.AreaPath like '%Tax Forms Client%')
		)
	)
and (wi.AreaPath like '%Benefits HR%'
or wi.AreaPath like '%Infrastructure%'
or wi.AreaPath like '%Integration%'
or (wi.AreaPath like '%Payroll Service Bureau%' and wi.AreaPath NOT LIKE '%Custom Report%' and wi.AreaPath NOT LIKE '%Vertex%')
or wi.AreaPath like '%CompanyX Tax%'
or wi.AreaPath like '%CompanyX Time%')
and wi.IterationPath not like '%Vertex%'
and wi.AreaPath not like '%NXGG2%'
and wi.IterationPath not like '%Production Tasks%'
and wi.AreaPath not like '%CompanyX Touch%'
and wi.IterationPath not like '%Custom Report%'
order by wi.AOS_VSTS_HotfixVersion desc, wi.AreaPath 





select distinct
  w.TFS_ID as WorkItemID
, w.Closed_Date as WorkItemClosedDate
, w.Work_Item_Type
, w.Title
, w.Program_Area
, w.Iteration_Closed
, w.AOS_VSTS_HotfixVersion
, tr.TestCaseId
, tr.TestRunId
, tr.ResultOutcome
, tr.ResultDate
, tr.Tester
from #WIs w
join FactWorkItemLinkHistory li on li.SourceWorkItemID = w.TFS_ID
join (select tr.TestCaseId
		, tr.TestRunId
		, tr.ResultOutcome
		, p.Name as Tester
		, max(tr.ResultDate) as ResultDate 
		from [dbo].[TestResultView] tr
		join DimPerson p on p.PersonSK = tr.ResultOwnerSK
		where tr.ResultDate >= '2018-09-01'
		group by tr.TestCaseId, tr.TestRunId, tr.ResultOutcome, p.Name) tr 
			on  tr.TestCaseId = li.TargetWorkItemID
order by WorkItemId, Closed_Date, TestCaseId, ResultDate

