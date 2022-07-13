select distinct
   CASE
	when i.IterationPath like '%Custom Reports%' then 'Custom Reports'
	when a.AreaPath like '%Payroll Service Bureau%' then 'Payroll SB'
    when a.AreaPath like '%CompanyX View%' then 'CompanyX View'
	when a.AreaPath like '%Tax Forms%' then 'Tax Forms'
	when a.AreaPath like '%Custom Report%' then 'Custom Reporting'
	when a.AreaPath like '%Benefits HR%' then 'Benefits HR'
	when a.AreaPath like '%Infrastructure%' then 'Infrastructure'
	when a.AreaPath like '%Integration%' then 'Integration & API'
	when a.AreaPath like '%Migration%' then 'Migration'
	when a.AreaPath like '%Local Print%' then 'Local Print'
	when a.AreaPath like '%Engage%' then 'Mojo'
	when a.AreaPath like '%Mobile%' then 'Mobile'
	when a.AreaPath like '%Time%' then 'Time'
	when (a.AreaPath like '%NXGG2%' or a.AreaPath like '%CompanyX Touch%') then 'Timeclocks'
	when a.AreaPath like '%Tax%' then 'Tax'
	when a.AreaPath like '%TFII - ISTF%' then 'Timeforce II'
	when a.AreaPath like '%CompanyX QA Automation' then 'QA Automation'
	else 'Other' 
	end as Program_Area
,  wi.System_Id as TFSWorkItemID
, ch.ChangesetID
, ch.ChangesetTitle
, ch.LastUpdatedDateTime as CheckedInDateTime
, p.Name as CheckedInBy
from DimChangeset ch 
join FactWorkItemChangeset fch on fch.ChangesetSK = ch.ChangesetSK
join DimWorkItem wi on wi.System_Id = fch.WorkItemID
join DimPerson p on p.PersonSK = ch.CheckedInBySK
join DimArea a on a.AreaSK = wi.AreaSK
join DimIteration i on i.IterationSK = wi.IterationSK
and wi.System_WorkItemType in ('Bug', 'Product Backlog Item')
and wi.Microsoft_VSTS_Common_ClosedDate >= '2018-09-01'
and wi.Microsoft_VSTS_Common_ClosedDate < '2019-08-03'
and (a.AreaPath like '%Benefits HR%'
or a.AreaPath like '%Infrastructure%'
or a.AreaPath like '%Integration%'
or (a.AreaPath like '%Payroll Service Bureau%' and a.AreaPath NOT LIKE '%Custom Report%' and a.AreaPath NOT LIKE '%Vertex%')
or a.AreaPath like '%CompanyX Tax%'
or a.AreaPath like '%CompanyX Time%')
and i.IterationPath not like '%Vertex%'
and a.AreaPath not like '%NXGG2%'
and i.IterationPath not like '%Production Tasks%'
and a.AreaPath not like '%CompanyX Touch%'
and i.IterationPath not like '%Custom Report%'
and wi.System_IsDeleted = 0


