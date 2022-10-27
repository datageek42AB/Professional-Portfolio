/*TASKS*/
select distinct task.System_Id as TaskID
, cwi.System_Title as TaskTitle
, cwi.System_CreatedBy as TaskCreatedBy
, cwi.Microsoft_VSTS_Scheduling_OriginalEstimate as TaskOriginalEstimate
, i.IterationSK
, a.AreaSK
, p.PersonSK as TaskResolvedBySK
, task.System_CreatedDate as TaskCreatedDate
, task.Microsoft_VSTS_Common_ClosedDate as TaskClosedDate
from CurrentWorkItemView cwi 
join DimWorkItem task on task.WorkItemSK = cwi.WorkItemSK
join DimPerson p on p.PersonSK = task.Microsoft_VSTS_Common_ResolvedBy__PersonSK
join DimIteration i on i.IterationPath = cwi.IterationPath
join DimArea a on a.AreaPath = cwi.AreaPath
where task.System_WorkItemType = 'Task'
and task.System_IsDeleted = 0
and task.System_State <> 'Removed'
and task.System_CreatedDate >= '2017-01-01'


/*Backlog Items*/
select distinct
  bi.WorkItemSK as BacklogItemSK
, bi.System_Id as BacklogItemID
, p.Name as ResolvedByName
, p.PersonSK as ResolvedBySK
, p.Domain
, p.Email
, bi.Microsoft_VSTS_Scheduling_Effort as Effort
, bi.System_State
, wi.AreaSK
, wi.IterationSK
, task.WorkItemSK as TaskWorkItemSK
, bi.System_CreatedDate as BICreatedDate
, bi.Microsoft_VSTS_Common_ClosedDate as BIClosedDate
from CurrentWorkItemView bi 
join DimWorkItem wi on wi.WorkItemSK = bi.WorkItemSK
join DimPerson p on wi.Microsoft_VSTS_Common_ResolvedBy__PersonSK = p.PersonSK
left join vFactLinkedCurrentWorkItem li on li.SourceWorkItemSK = bi.WorkItemSK
left join CurrentWorkItemView task on task.WorkItemSK = li.TargetWorkItemSK
	and task.System_WorkItemType in ('Task')
	and task.System_IsDeleted = 0
	and task.System_State <> 'Removed'
where bi.System_WorkItemType in ('Bug', 'Product Backlog Item')
and bi.System_IsDeleted = 0
and bi.System_State <> 'Removed'
and bi.Microsoft_VSTS_Common_ClosedDate >= '2017-01-01'
and bi.IterationPath like '%5.0.%'


/*PERSON*/
select p.PersonSK
, p.Name as EmployeeName
, CASE
	when p.name in ('LIST ANONYMIZED') then 'BA'
	when p.name in ('LIST ANONYMIZED') then 'QA'
	when p.name in ('LIST ANONYMIZED') then 'Dev'	
	else 'Other'
	end as Role
from DimPerson p
where p.domain in ('LIST ANONYMIZED')


/*AREA*/
SELECT a.AreaSK
, a.AreaPath
, CASE
	when a.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when a.AreaPath like '%Tax Forms%' then 'Tax Forms'
	when a.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when a.AreaPath like '%Infrastructure%' then 'Infrastructure'
	when a.AreaPath like '%Local Print%' then 'Local Print'
	when a.AreaPath like '%Engage%' then 'Engage'
	when a.AreaPath like '%Mobile%' then 'Mobile'
	when (a.AreaPath like '%Time%' or a.AreaPath like '%NXGG2%') then 'Time'
	when a.AreaPath like '%Tax%' then 'Tax'
	else 'Other' 
	end as Area
FROM DimArea a
where a.AreaPath not like '\{Deleted%'




/*Iteration-Sprint-Release*/
Select distinct i.IterationSK
, CASE
	when i.IterationPath like '%TFII - ISTF%' then 'No Release'
	when i.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', i.IterationPath), 27), 6)
	when i.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(i.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', i.IterationPath), 27), 6), 3)
	when i.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(i.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', i.IterationPath), 27), 7), 6)
	when i.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(i.IterationPath, PATINDEX('%\V[0-9].[0-9]', i.IterationPath), 5), 3)
	when i.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when i.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when i.IterationPath like '%CompanyX View%' then 'No Release'
    when i.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when i.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when i.IterationPath like '%CompanyX Touch%' then 'No Release'
	when i.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%\NXGG2\Release%', i.IterationPath), 28), 21)
	when i.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when i.IterationPath like '%\Pending Issues%' then 'No Release'
	when i.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when i.IterationPath like '%\Time\Future%' then 'No Release'
	when i.IterationPath like '%\PayrollOffice' then 'No Release'
	when i.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(i.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', i.IterationPath), 7)
	else i.IterationPath
	End As Release
, CASE
	when i.IterationPath like '%Sprint 0[0-9].%' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%Sprint %', i.IterationPath), 11), 2) 
	when i.IterationPath like '\TFII - ISTF\%' then SUBSTRING( i.IterationPath, PATINDEX('%[0-9]%', i.IterationPath), 27)
	when i.IterationPath like '%Sprint [0-9].[0-9].[0-9]' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%Sprint [0-9].[0-9].[0-9]', i.IterationPath), 12), 2)
	when i.IterationPath like '%Sprint [0-9].[0-9]' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%Sprint [0-9].[0-9]', i.IterationPath), 10), 2)
	when i.IterationPath like '%[0-9].[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', i.IterationPath), 6), 3)
	when i.IterationPath like '%Release [0-9].[0-9]' then SUBSTRING(i.iterationPath, PATINDEX('%Release [0-9].[0-9]', i.IterationPath), 11)
	when i.IterationPath like '%Sprint [0-9]' then CONCAT('.', RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%Sprint [0-9]', i.IterationPath), 8),1)) 
	when i.IterationPath like '%Sprint [0-9][0-9]' then CONCAT('.', RIGHT(SUBSTRING(i.IterationPath, PATINDEX('%Sprint [0-9][0-9]', i.IterationPath), 9),2)) 
	end as Sprint
from DimIteration i
where IterationSK <> 614
and i.IterationPath not like '%Deleted%'



select distinct c.System_Id as BugID
, c.System_CreatedDate as BugCreatedDate
, c.Microsoft_VSTS_Common_ClosedDate as BugClosedDate
, CASE 
	when c.Microsoft_VSTS_Scheduling_Effort is NULL then 0
	else c.Microsoft_VSTS_Scheduling_Effort
	End as BugEffort
, CASE
	when c.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
    when c.AreaPath like '%CompanyX View%' then 'CompanyX View'
	when c.AreaPath like '%Tax Forms%' then 'Tax Forms'
	when c.AreaPath like '%Custom Report%' then 'Custom Reporting'
	when c.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when c.AreaPath like '%Infrastructure%' then 'Infrastructure'
	when c.AreaPath like '%Integration%' then 'Integration & API'
	when c.AreaPath like '%Migration%' then 'Migration'
	when c.AreaPath like '%Local Print%' then 'Local Print'
	when c.AreaPath like '%Engage%' then 'Mojo'
	when c.AreaPath like '%Mobile%' then 'Mobile'
	when (c.AreaPath like '%NXGG2%' or c.AreaPath like '%CompanyX Touch%' or c.AreaPath like '%PayrollOffice\Time Clocks%' or c.AreaPath like '%CompanyX Time\%clock%') then 'Timeclocks'
	when c.AreaPath like '%Time%' then 'Time'
	when c.AreaPath like '%Tax%' then 'Tax'
	when c.AreaPath like '%TFII - ISTF%' then 'Timeforce II'
	when c.AreaPath like '%CompanyX QA Automation' then 'QA Automation'
	else 'Other'
	end as BugFunctionalArea
, c.IterationPath as BugIteration
, c.System_State as BugState
, c.System_Reason as BugReason
, c.System_AssignedTo as BugOwner
from CurrentWorkItemView c 
where 
    c.System_IsDeleted = 0
and c.System_Reason NOT IN ('Duplicate', 'Obsolete', 'Deferred', 'Unable to Reproduce')
and c.System_WorkItemType ='Bug'
and c.System_CreatedDate >= '2016-05-01' 
and c.System_CreatedDate <= '2016-07-01'
order by 6





