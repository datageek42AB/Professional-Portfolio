Declare @package datetime
Declare @prod datetime
Declare @currentiteration varchar(30)
Declare @nextiteration varchar(30)
Declare @area varchar(30)
Declare @hotfixVer varchar(10)
Declare @hotfixVer2 varchar(10)
Declare @iterationpath varchar (10)


Set @area = '%Benefits HR%'
Set @currentiteration = '%\6.4\%'
Set @nextiteration = '%\6.5\%'
Set @package = '2019-11-11 23:59:59.997'
Set @prod = '2019-12-6'
Set @hotfixVer = '%6.3%'
Set @hotfixVer2 = '%6.4%'

/* change @package to @prod */

/* All points in Target */
select distinct
sum(wih.Microsoft_VSTS_Scheduling_Effort) as TargetCompleted
from DimWorkItem wi
join DimArea a on a.AreaSK = wi.AreaSK
join DimIteration i on i.IterationSK = wi.IterationSK
join factWorkItemHistory wih on wih.RevisionCount = 1 and wi.workItemSK = wih.workItemSK
join (select wid.System_Id
				, max(wid.System_ChangedDate) as LatestChange
                from dimworkitem wid
				join DimIteration i on i.IterationSK = wid.IterationSK
				join DimArea a on a.AreaSK = wid.AreaSK
                where wid.system_changeddate <= @package
                and wid.system_workItemType in ('Product Backlog Item', 'Bug')
				group by wid.System_Id
			) cwi
		on cwi.System_Id = wi.System_Id and cwi.LatestChange = wi.System_ChangedDate
 where
                    i.IterationPath like @currentiteration 
					and i.IterationPath not like '%Tax Forms%'
					and wi.System_ChangedDate <= @package
					and wi.System_IsDeleted = 0
					and a.AreaPath like @area
					and wi.System_State = 'Closed'


/* Regression Points for unfinished WIs*/
select distinct
sum(wih.Microsoft_VSTS_Scheduling_Effort) as RegressionCompleted
from DimWorkItem wi
join DimArea a on a.AreaSK = wi.AreaSK
join DimIteration i on i.IterationSK = wi.IterationSK
join factWorkItemHistory wih on wih.RevisionCount = 1 and wi.workItemSK = wih.workItemSK
join (select wid.System_Id
				, max(wid.system_changedDate) as LatestChange
                from dimworkitem wid
				join DimIteration i on i.IterationSK = wid.IterationSK
				join DimArea a on a.AreaSK = wid.AreaSK
                where wid.System_ChangedDate > @package
				and wid.system_changedDate < @prod
                and wid.system_workItemType in ('Product Backlog Item', 'Bug')
				and i.iterationPath like @nextiteration 
				group by wid.System_Id
			) cwi
		on cwi.System_Id = wi.System_Id and cwi.LatestChange = wi.system_changedDate
 where
					i.iterationPath like @nextiteration 
					and (wi.AOS_VSTS_HotfixVersion like @hotfixVer2 or wi.AOS_VSTS_HotfixVersion like @hotfixVer)
					and i.IterationPath not like '%Tax Forms%'
					and wi.System_ChangedDate > @package
					and wi.system_changedDate < @prod
					and wi.System_IsDeleted = 0
					and a.AreaPath like @area
					and wi.System_State = 'Closed'
					and wi.AOS_VSTS_HotfixVersion >= '6.3'


select distinct
wi.System_Id
, i.IterationPath
, wih.Microsoft_VSTS_Scheduling_Effort as effort
, wi.AOS_VSTS_HotfixVersion
from DimWorkItem wi
join DimArea a on a.AreaSK = wi.AreaSK
join DimIteration i on i.IterationSK = wi.IterationSK
join factWorkItemHistory wih on wih.RevisionCount = 1 and wi.workItemSK = wih.workItemSK
join (select wid.System_Id
				, max(wid.System_ChangedDate) as LatestChange
                from dimworkitem wid
				join DimIteration i on i.IterationSK = wid.IterationSK
				join DimArea a on a.AreaSK = wid.AreaSK
                where wid.system_changeddate <= @package
                and wid.system_workItemType in ('Product Backlog Item', 'Bug')
				group by wid.System_Id
			) cwi
		on cwi.System_Id = wi.System_Id and cwi.LatestChange = wi.System_ChangedDate
 where
                    i.IterationPath like @currentiteration 
					and i.IterationPath not like '%Tax Forms%'
					and wi.System_ChangedDate <= @package
					and wi.System_IsDeleted = 0
					and a.AreaPath like @area
					and wi.System_State = 'Closed'
