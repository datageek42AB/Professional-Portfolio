select wi.System_Id as WorkItemID
, wi.System_WorkItemType as WorkItemType
, wi.Microsoft_VSTS_Common_ResolvedBy as Developer
, CASE
	when wi.Microsoft_VSTS_Scheduling_Effort = 0 then 0.7
	else wi.Microsoft_VSTS_Scheduling_Effort
	end as Effort
, wi.Microsoft_VSTS_Common_ClosedDate
, CASE
	when wi.IterationPath like '%\PayrollSB\Sprint%' then 'Payroll SB'
	when wi.IterationPath like '%\Tax\Sprint%' then 'Tax'
	when wi.IterationPath like '%\BenHR\Sprint%' then 'Benefits HR'
	when wi.IterationPath like '%\Integration\Sprint%' then 'Integration & API'
	when wi.IterationPath like '%\Time\Sprint%' then 'Time'
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%iSolved Tax%' then 'Tax'
	when wi.AreaPath like '%PayrollOffice\Integration%' then 'Integration & API'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%iSolved Time%' then 'Time'
	end as Area 
, wi.IterationPath
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]\Time%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 6), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '%[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
	when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%iSolved View%' then 'No Release'
	when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%iSolved Mobile%' then 'No Release'
	when wi.IterationPath like '%iSolved Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	when wi.IterationPath = '\PayrollOffice' then 'No Release'
	when wi.IterationPath = '\PayrollOffice\CCB' then 'No Release'
	when wi.IterationPath like '\PayrollOffice\V_' then 'No Release'
	when wi.IterationPath = '\PayrollOffice\Production Tasks' then 'No Release'
	when wi.IterationPath = '\PayrollOffice\Vertex' then 'No Release'
	else wi.IterationPath
	End As Release
, RIGHT(wi.IterationPath, 1) as Sprint 
, task.System_CreatedBy as CreatedBy
, task.System_Id as TaskID
, task.Microsoft_VSTS_Scheduling_OriginalEstimate as TaskHours
, task.System_Title as TaskTitle
, task.Microsoft_VSTS_Common_ResolvedBy as TaskResolvedBy
from CurrentWorkItemView wi
join vFactLinkedCurrentWorkItem li on li.SourceWorkItemSK = wi.WorkItemSK
join CurrentWorkItemView task on task.WorkItemSK = li.TargetWorkitemSK 
	and task.System_WorkItemType = 'Task'
	and task.System_IsDeleted = 0
where wi.System_WorkItemType in ('Product Backlog Item', 'Bug')
and wi.System_IsDeleted = 0
and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-02-01'
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%iSolved Tax%'
	or wi.AreaPath like '%PayrollOffice\Integration%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%iSolved Time%')
and wi.Microsoft_VSTS_Common_ResolvedReason not in ('Duplicate', 'Cut', 'Unable to Reproduce')
order by wi.IterationPath




