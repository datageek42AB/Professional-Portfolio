/*---------------------------------------------
				Open Items Query
  ---------------------------------------------*/

select wi.System_Id as ID
, wi.System_CreatedDate as CreatedDate
, wi.System_State as State
, d.AOS_VSTS_CustomReporting_ReportCategory
, d.AOS_VSTS_RequestedDueDate
, d.AOS_VSTS_Environment
, wi.System_AssignedTo as AssignedTo
, wi.Infinisource_VSTS_TimeBA_AssignedBA as AssignedBA
, wi.Microsoft_VSTS_Common_Rank as Rank
, wi.AOS_VSTS_CustomReporting_WorkType as RptWorkType
from CurrentWorkItemView wi 
join DimWorkItem d on d.WorkItemSK = wi.WorkItemSK
where wi.AreaPath like '%PayrollOffice%'
and wi.IterationPath like '%Custom Reports%'
and (wi.Microsoft_VSTS_Common_Rank <> '0000' or wi.Microsoft_VSTS_Common_Rank is NULL)
and wi.System_State not in ('Design', 'Closed')
and wi.System_WorkItemType <> 'Task'
and wi.System_CreatedDate < '12/01/2019'

/*---------------------------------------------
				New Requests Query
  ---------------------------------------------*/

select wi.System_Id as ID
, dateadd(hour, -4, wi.System_CreatedDate) as CreatedDate
, wi.System_State as State
, d.AOS_VSTS_CustomReporting_ReportCategory
, d.AOS_VSTS_RequestedDueDate
, d.AOS_VSTS_Environment
, wi.System_AssignedTo as AssignedTo
, wi.Infinisource_VSTS_TimeBA_AssignedBA as AssignedBA
, wi.Microsoft_VSTS_Common_Rank as Rank
, wi.AOS_VSTS_CustomReporting_WorkType as RptWorkType
from CurrentWorkItemView wi 
join DimWorkItem d on d.WorkItemSK = wi.WorkItemSK
where wi.AreaPath like '%PayrollOffice%'
and wi.IterationPath like '%Custom Reports%'
and dateadd(hour, -4, wi.System_CreatedDate) >= '2019-11-01'
and dateadd(hour, -4, wi.System_CreatedDate) < '2019-12-01'
and (wi.Microsoft_VSTS_Common_Rank <> '99' or wi.Microsoft_VSTS_Common_Rank is NULL)
and wi.System_State <> 'Design'
and wi.System_WorkItemType <> 'Task'

/*---------------------------------------------
			Closed Requests Query
  ---------------------------------------------*/

select wi.System_Id as ID
, wi.System_CreatedDate as CreatedDate
, wi.System_State as State
, d.AOS_VSTS_CustomReporting_ReportCategory
, d.AOS_VSTS_RequestedDueDate
, d.AOS_VSTS_Environment
, wi.System_AssignedTo as AssignedTo
, wi.Microsoft_VSTS_Common_ResolvedBy as ResolvedBy
, wi.Microsoft_VSTS_Common_Rank as Rank
, wi.AOS_VSTS_CustomReporting_WorkType as RptWorkType
from CurrentWorkItemView wi 
join DimWorkItem d on d.WorkItemSK = wi.WorkItemSK
where wi.AreaPath like '%PayrollOffice%'
and wi.IterationPath like '%Custom Reports%'
and d.Microsoft_VSTS_Common_ClosedDate >= '2019-11-01'
and d.Microsoft_VSTS_Common_ClosedDate < '2019-12-01'
and (wi.Microsoft_VSTS_Common_Rank <> '99' or wi.Microsoft_VSTS_Common_Rank is NULL)
and wi.System_WorkItemType <> 'Task'
and wi.System_State = 'Closed'

/*---------------------------------------------
				Billing Query
  ---------------------------------------------*/

select wi.System_Id as ID
, wi.System_CreatedDate as CreatedDate
, wi.System_State as State
, wi.Microsoft_VSTS_Common_ClosedDate as ClosedDate
, d.AOS_VSTS_CustomReporting_ReportCategory
, d.AOS_VSTS_RequestedDueDate
, d.AOS_VSTS_QuotedPrice as QuotedPrice
, d.AOS_VSTS_Environment
, wi.System_AssignedTo as AssignedTo
, wi.Microsoft_VSTS_Common_ResolvedBy as ResolvedBy
, wi.Microsoft_VSTS_Common_Rank as Rank
, wi.AOS_VSTS_CustomReporting_WorkType as RptWorkType
from CurrentWorkItemView wi 
join DimWorkItem d on d.WorkItemSK = wi.WorkItemSK
where wi.IterationPath like '%Custom Reports%'
and d.AOS_VSTS_QuotedPrice > '0.00'
and d.AOS_VSTS_CustomReporting_QuotedPriceApproval = 'Approved'
and d.AOS_VSTS_RequestedDueDate >= '2019-11-01'
and d.AOS_VSTS_RequestedDueDate < '2019-12-01'
and (wi.Microsoft_VSTS_Common_Rank <> '99' or wi.Microsoft_VSTS_Common_Rank IS NULL)
and wi.System_State = 'Closed'

