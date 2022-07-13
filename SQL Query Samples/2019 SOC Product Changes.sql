select wi.System_Id as TFS_ID
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
, wi.IterationPath as Iteration_Implemented
, wi.System_State
, wi.System_Reason
, wi.System_CreatedDate as Created_Date
, wi.Microsoft_VSTS_Common_ClosedDate as Closed_Date 
, wi.AOS_VSTS_HotfixVersion
from CurrentWorkItemView wi
where wi.System_WorkItemType in ('Bug', 'Product Backlog Item')
and wi.System_State = 'Closed'
and wi.System_Reason not in ('Obsolete', 'Duplicate', 'As Designed', 'Unable to Reproduce', 'Deferred', 'Cut')
and wi.System_IsDeleted = 0
and wi.Microsoft_VSTS_Common_ClosedDate >= '2018-09-01'
and (wi.Microsoft_VSTS_Common_ClosedDate < '2019-06-14'
	OR (wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-03' 
		and (wi.Infinisource_VSTS_EnvironmentFoundIn <> 'RCQA' or wi.System_Title not like '%QAB%')
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


