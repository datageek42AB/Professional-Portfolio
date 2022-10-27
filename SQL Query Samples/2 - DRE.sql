/*-----------------------------------------------------------
						Closed	Reworks
  -----------------------------------------------------------*/
select wi.System_Id as ReworkID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate 
, wi.System_IsDeleted 
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Task'
and (wi.System_Title like '%rework%' or wi.System_Title like '%re-work%')
and ((wi.IterationPath like '%V5%5.0.06%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2018-10-15' and wi.Microsoft_VSTS_Common_ClosedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.Microsoft_VSTS_Common_ClosedDate > '2018-12-03' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-02-04' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-04-01' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-06-03' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-08-05' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-09-30' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-12-06')
	)
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and wi.System_State = 'Done'
and wi.System_IsDeleted = 0


/*-----------------------------------------------------------
						Removed	Reworks
  -----------------------------------------------------------*/
select wi.System_Id as ReworkID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate as Estimate
, wi.System_IsDeleted 
, wi.System_ChangedDate
, hi.ClosedDate
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
join (select h.System_Id
		, max(h.Microsoft_VSTS_Common_ClosedDate) as ClosedDate
		from DimWorkItem h
		group by h.System_Id) hi on hi.System_Id = wi.System_Id
			and hi.ClosedDate = wi.System_ChangedDate
where wi.System_WorkItemType = 'Task'
and (wi.System_Title like '%rework%' or wi.System_Title like '%re-work%')
and ((wi.IterationPath like '%V5%5.0.06%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2018-10-15' and wi.Microsoft_VSTS_Common_ClosedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.Microsoft_VSTS_Common_ClosedDate > '2018-12-03' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-02-04' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-04-01' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-06-03' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-08-05' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.Microsoft_VSTS_Common_ClosedDate >= '2019-09-30' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-12-06')
	)
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and wi.System_State = 'Removed'
and wi.System_IsDeleted = 0

select * from DimWorkItem order by System_Id

/*-----------------------------------------------------------
						Deleted	Reworks
  -----------------------------------------------------------*/
select wi.System_Id as ReworkID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate 
, wi.System_IsDeleted 
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Task'
and (wi.System_Title like '%rework%' or wi.System_Title like '%re-work%')
and ((wi.IterationPath like '%V5%5.0.06%' and wi.System_CreatedDate >= '2018-10-15' and wi.System_CreatedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.System_CreatedDate > '2018-12-03' and wi.System_CreatedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.System_CreatedDate >= '2019-02-04' and wi.System_CreatedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.System_CreatedDate >= '2019-04-01' and wi.System_CreatedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.System_CreatedDate >= '2019-06-03' and wi.System_CreatedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.System_CreatedDate >= '2019-08-05' and wi.System_CreatedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.System_CreatedDate >= '2019-09-30' and wi.System_CreatedDate < '2019-12-06'))
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and wi.System_IsDeleted = 1

/*-----------------------------------------------------------
						Open Reworks
  -----------------------------------------------------------*/
select wi.System_Id as ReworkID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate 
, wi.System_IsDeleted 
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Task'
and (wi.System_Title like '%rework%' or wi.System_Title like '%re-work%')
and ((wi.IterationPath like '%V5%5.0.06%' and wi.System_CreatedDate >= '2018-10-15' and wi.System_CreatedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.System_CreatedDate > '2018-12-03' and wi.System_CreatedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.System_CreatedDate >= '2019-02-04' and wi.System_CreatedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.System_CreatedDate >= '2019-04-01' and wi.System_CreatedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.System_CreatedDate >= '2019-06-03' and wi.System_CreatedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.System_CreatedDate >= '2019-08-05' and wi.System_CreatedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.System_CreatedDate >= '2019-09-30' and wi.System_CreatedDate < '2019-12-06')
	)
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and wi.System_IsDeleted = 0
and wi.System_State not in ('Done', 'Removed')


/*-----------------------------------------------------------
			  Closed QAB Bugs or Bugs found in RCQA
  -----------------------------------------------------------*/
select wi.System_Id as BugID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate Estimate
, wi.System_IsDeleted 
, wi.Infinisource_VSTS_EnvironmentFoundIn as Environment
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Bug'
and ((wi.IterationPath like '%V5%5.0.06%' and wi.System_CreatedDate >= '2018-10-15' and wi.System_CreatedDate < '2018-12-14' and wi.Microsoft_VSTS_Common_ClosedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.System_CreatedDate > '2018-12-03' and wi.System_CreatedDate < '2019-02-15' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.System_CreatedDate >= '2019-02-04' and wi.System_CreatedDate < '2019-04-12' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.System_CreatedDate >= '2019-04-01' and wi.System_CreatedDate < '2019-06-14' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.System_CreatedDate >= '2019-06-03' and wi.System_CreatedDate < '2019-08-16' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.System_CreatedDate >= '2019-08-05' and wi.System_CreatedDate < '2019-10-11' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.System_CreatedDate >= '2019-09-30' and wi.System_CreatedDate < '2019-12-06' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-12-06'))
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and (wi.System_Title like '%QAB%' or (wi.Infinisource_VSTS_EnvironmentFoundIn = 'RCQA' and wi.AreaPath not like '%Infrastructure%'))
and wi.System_Reason not in ('Duplicate', 'Unable to Reproduce', 'As Designed')
and wi.System_State = 'Closed'
and wi.System_IsDeleted = 0

/*-----------------------------------------------------------
			  Deferred QAB Bugs or Bugs found in RCQA
  -----------------------------------------------------------*/
select wi.System_Id as BugID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate Estimate
, wi.System_IsDeleted 
, wi.Infinisource_VSTS_EnvironmentFoundIn as Environment
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Bug'
and ((wi.IterationPath like '%V5%5.0.06%' and wi.System_CreatedDate >= '2018-10-15' and wi.System_CreatedDate < '2018-12-14' and wi.Microsoft_VSTS_Common_ClosedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.System_CreatedDate > '2018-12-03' and wi.System_CreatedDate < '2019-02-15' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.System_CreatedDate >= '2019-02-04' and wi.System_CreatedDate < '2019-04-12' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.System_CreatedDate >= '2019-04-01' and wi.System_CreatedDate < '2019-06-14' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.System_CreatedDate >= '2019-06-03' and wi.System_CreatedDate < '2019-08-16' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.System_CreatedDate >= '2019-08-05' and wi.System_CreatedDate < '2019-10-11' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.System_CreatedDate >= '2019-09-30' and wi.System_CreatedDate < '2019-12-06' and wi.Microsoft_VSTS_Common_ClosedDate < '2019-12-06'))
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and (wi.System_Title like '%QAB%' or (wi.Infinisource_VSTS_EnvironmentFoundIn = 'RCQA' and wi.AreaPath not like '%Infrastructure%'))
and wi.System_Reason not in ('Duplicate', 'Unable to Reproduce', 'As Designed')
and wi.System_Reason = 'Deferred'
and wi.System_IsDeleted = 0


/*-----------------------------------------------------------
			  Open QAB Bugs or Bugs found in RCQA
  -----------------------------------------------------------*/
select wi.System_Id as BugID
, wi.System_Title
, wi.System_State
, wi.System_Reason
, wi.Microsoft_VSTS_Scheduling_OriginalEstimate Estimate
, wi.System_IsDeleted 
, wi.Infinisource_VSTS_EnvironmentFoundIn as Environment
, CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.IterationPath like '%TFII - ISTF%' then 'No Release'
	when wi.IterationPath like '%\V[0-9].[0-9]\[0-9].[0-9].[0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 6)
	when wi.IterationPath like '%\V[0-9]' then 'No Release'
	when wi.IterationPath like '%\Time\6.[0-9].[0-9][0-9]' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\Time\6.[0-9]%', wi.IterationPath), 9), 3)
	when wi.IterationPath like '%\[0-9].[0-9].[0-9][0-9]\%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('\[0-9].[0-9].[0-9][0-9]\%', wi.IterationPath), 27), 6)
	when wi.IterationPath like '%V[0-9]\[0-9].[0-9]%' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9]\[0-9].[0-9]%', wi.IterationPath), 27), 6), 3)
	when wi.IterationPath like '%V[0-9].[0-9].[0-9][0-9]' then RIGHT(LEFT(SUBSTRING(wi.IterationPath, PATINDEX('%V[0-9].[0-9].[0-9][0-9]', wi.IterationPath), 27), 7), 6)
	when wi.IterationPath like '%\V[0-9].[0-9]' then right(SUBSTRING(wi.IterationPath, PATINDEX('%\V[0-9].[0-9]', wi.IterationPath), 5), 3)
	when wi.IterationPath like '\NXGG2\Sprint%' then 'No Release'
    when wi.IterationPath like '%\Engage\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX View%' then 'No Release'
    when wi.IterationPath like '%\Mobile\Sprint%' then 'No Release'
	when wi.IterationPath like '%CompanyX Mobile%' then 'No Release'
	when wi.IterationPath like '%CompanyX Touch%' then 'No Release'
	when wi.IterationPath like '%\NXGG2\Release%' then RIGHT(SUBSTRING(wi.IterationPath, PATINDEX('%\NXGG2\Release%', wi.IterationPath), 28), 21)
	when wi.IterationPath like '%\NXGG2' then 'No Release'
	when wi.IterationPath like '%Unscheduled Roadmap Items' then 'No Release'
	when wi.IterationPath like '%\Pending Issues%' then 'No Release'
	when wi.IterationPath like '%\Unscheduled Items%' then 'No Release'
	when wi.IterationPath like '%\Time\Future%' then 'No Release'
	when wi.IterationPath like '%\PayrollOffice' then 'No Release'
	when wi.IterationPath like '%\Engage\Q[0-9]-[0-9][0-9][0-9][0-9]' then SUBSTRING(wi.IterationPath, PATINDEX('%Q[0-9]-[0-9][0-9][0-9][0-9]', wi.IterationPath), 7)
	else wi.IterationPath
	End As Release
from CurrentWorkItemView wi
where wi.System_WorkItemType = 'Bug'
and ((wi.IterationPath like '%V5%5.0.06%' and wi.System_CreatedDate >= '2018-10-15' and wi.System_CreatedDate < '2018-12-14')
	or (wi.IterationPath like '%V5%5.0.07%' and wi.System_CreatedDate > '2018-12-03' and wi.System_CreatedDate < '2019-02-15')
	or (wi.IterationPath like '%V6%6.0%' and wi.System_CreatedDate >= '2019-02-04' and wi.System_CreatedDate < '2019-04-12')
	or (wi.IterationPath like '%V6%6.1%' and wi.System_CreatedDate >= '2019-04-01' and wi.System_CreatedDate < '2019-06-14')
	or (wi.IterationPath like '%V6%6.2%' and wi.System_CreatedDate >= '2019-06-03' and wi.System_CreatedDate < '2019-08-16')
	or (wi.IterationPath like '%V6%6.3%' and wi.System_CreatedDate >= '2019-08-05' and wi.System_CreatedDate < '2019-10-11')
	or (wi.IterationPath like '%V6%6.4%' and wi.System_CreatedDate >= '2019-09-30' and wi.System_CreatedDate < '2019-12-06'))
and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
and (wi.System_Title like '%QAB%' or (wi.Infinisource_VSTS_EnvironmentFoundIn = 'RCQA' and wi.AreaPath not like '%Infrastructure%'))
and wi.System_Reason not in ('Duplicate', 'Unable to Reproduce', 'As Designed')
and wi.System_State <> 'Closed' and wi.System_State <> 'Removed'
and wi.SYstem_IsDeleted = 0




/*-----------------------------------------------------------
	Bugs or PBIs with NetSuite Issue #s Opened by Release 
  -----------------------------------------------------------*/

  select wi.System_Id
  , wi.System_Title
  , wi.System_WorkItemType as WorkItemType
  , wi.System_CreatedDate as CreatedDate
  , wi.AOS_VSTS_HotfixVersion
  , CASE
	when wi.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
	when wi.AreaPath like '%CompanyX Tax%' then 'Tax'
	when wi.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when wi.AreaPath like '%Integration%' then 'Integration & API'
	when wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%' then 'Time'
	else wi.AreaPath
	end as WorkItemFunctionalArea 
, CASE
	when wi.System_CreatedDate >= '2018-12-14' and wi.System_CreatedDate < '2019-02-15' then '5.0.06'
	when wi.System_CreatedDate >= '2019-02-15' and wi.System_CreatedDate < '2019-04-12' then '5.0.07'
	when wi.System_CreatedDate >= '2019-04-12' and wi.System_CreatedDate < '2019-06-14' then '6.0'
	when wi.System_CreatedDate >= '2019-06-14' and wi.System_CreatedDate < '2019-08-16' then '6.1'
	when wi.System_CreatedDate >= '2019-08-16' and wi.System_CreatedDate < '2019-10-11' then '6.2'
	when wi.System_CreatedDate >= '2019-10-11' and wi.System_CreatedDate < '2019-12-06' then '6.3'
	when wi.System_CreatedDate >= '2019-12-06' and wi.System_CreatedDate < '2020-02-14' then '6.4'
	End As Release
  from CurrentWorkItemView wi
  where wi.System_WorkItemType in ('Bug', 'Product Backlog Item')
  and wi.System_IsDeleted = 0
  and wi.System_State <> 'Removed'
  and wi.AOS_VSTS_NetSuiteIssueNumber is not NULL
  and wi.AOS_VSTS_NetSuiteIssueNumber <> ''
  and (wi.AreaPath like '%Payroll Service Bureau%' 
	or wi.AreaPath like '%CompanyX Tax%' 
	or wi.AreaPath like '%Benefits HR%' 
	or wi.AreaPath like '%Integration%' 
	or wi.AreaPath like '%CompanyX Time%' and wi.AreaPath not like '%CompanyX Time\%clock%')
  and (wi.Infinisource_VSTS_EnvironmentFoundIn not in ('RCQA', 'SQLDev', 'CSS') or wi.Infinisource_VSTS_EnvironmentFoundIn is NULL)
  and wi.System_CreatedDate >= '2018-12-14'
  and wi.System_IsDeleted = 0


