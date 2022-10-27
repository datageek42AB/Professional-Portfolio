declare @client varchar(20)
set @client = 'XXCLIENTNAMEXX'

--SQL
IF Object_id('tempdb..#Dimension1Dimension2') IS NOT NULL drop table #Dimension1Dimension2
IF Object_id('tempdb..#Dimenson4') IS NOT NULL drop table #Dimenson4
IF Object_id('tempdb..#Dimenson5') IS NOT NULL drop table #Dimenson5
IF Object_id('tempdb..#Dimenson6') IS NOT NULL drop table #Dimenson6
IF Object_id('tempdb..#Dimenson7') IS NOT NULL drop table #Dimenson7
IF Object_id('tempdb..#Dimenson7Results') IS NOT NULL drop table #Dimenson7Results
--[Remaining table cleanup redacted]

/* Dimension1 & Dimension2 Data */
select
		c.dimDimension1Key
	,	c.Dimension1_ID
	,	c.Dimension1Name as Dimension1
	,	p.dimDimension2Key
	,	p.Dimension2_ID
	,	p.Dimension2_Name as Dimension2
into #Dimension1Dimension2
from [X].[vw_dimDimension1] c
left join [X].vw_dimDimension2 p on p.Dimension1_ID = c.Dimension1_ID and p.DW_Current_Record = 1
where Dimension1Name = 'XXCLIENTNAMEXX'
	and c.DW_Current_Record = 1;

/* Isolate Relevant Dimension3s for Dimension1 Dimension2  */
select 
		c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_Type
	,	c.Dimension3_Status
	,	c.Dimension1_ID
	,	c.Dimension4_ID
	,	c.Dimension2_ID
	,	c.Dimension8_ID
	,	c.Source_Created_Date
	,	c.Closed_On
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.Postal_Address_ID
--	,	c.Product_ID
	,	c.Dimenson7_ID
	,	c.Dimension3_Owner
into #Dimension3
from [X].vw_dimDimension3 c 
join #Dimension1Dimension2 cp on cp.Dimension1_ID = c.Dimension1_ID
	and cp.Dimension2_ID = c.Dimension2_ID
where c.Dimension3_Status not in ('Status1')				
	and c.DW_Current_record = 1
	and (
		(c.Dimension3_Record_Type = 'Type1' and c.Dimension3_Sub_Type in ('SubType1', 'SubType2', 'SubType3'))
			or (c.Dimension3_Record_Type = 'Type2')
			or (c.Dimension3_Record_Type = 'Type3' and c.Dimension3_Sub_Type IN ('SubType1', 'SubType2', 'SubType3'))
			or (c.Dimension3_Record_Type = 'Type4' and c.Dimension3_Sub_Type IN ('SubType1', 'SubType2', 'SubType3'))
		);

/* Dimension4 Data */
/*	On Track Dimension4s */
select distinct
		CAST('On Track' as varchar(30)) as Dimension4_Category
	,	p.Dimension4_ID
	,	p.Name_First FIRST_NAME
	,	p.Name_Last LAST_NAME
	,	p.DATE_OF_BIRTH
	,	rb.dimDimenson5Key
	,	p.CRM_Dimension4_ID
	,	cp.Dimension2
	,	cp.Dimension2_ID
	,	b.Dimension8_ID
	,	b.Dimension8_NAME as Dimension8
	,	cp.Dimension1_ID
	,	cp.Dimension1
	,	cp.dimDimension1Key
	,	CAST(NULL as varchar(40)) as Support_Contact
into #Dimension4
from [X].[dimDimension4] p 
join #Dimension1Dimension2 cp on cp.Dimension1_ID = p.Dimension1_ID
join [X].vw_dimDimension5 rb on rb.Dimension4_ID = p.Dimension4_ID 
	and cp.Dimension2_ID = rb.Dimension2_ID 
	and rb.dw_Current_record = 1
join #ZepDimension3 c on c.Dimension4_ID = p.Dimension4_ID 
	and c.Dimension2_ID = rb.Dimension2_ID
	and c.Dimension6_ID = rb.Dimension6_ID	
	and c.Dimension3_Status not in ('Completed', 'Cancelled')
	and c.Dimension3_Record_Type <> 'TypeM'	
join [X].dimDimension6 b on rb.Dimension6_ID = b.Dimension6_ID
where p.dw_current_record = 1 
	and p.status = 'Active';


/* Related Dimension6 Data */
select  distinct
		rb.Dimension4_Id
	,	rb.Dimension2_Id
	,	rb.Dimension6_Id
	,	b.Dimension6_Name as Dimension6
	,	rb.Dimension5_Id
	,	rb.dimDimension5Key
into #Dimension5
from [X].[vw_dimDimension5] rb 
join #Dimension4 p on rb.Dimension4_ID = p.Dimension4_ID
join #Dimension1Dimension2 cp on cp.Dimension2_ID = rb.Dimension2_ID
join [X].dimDimension6 b on rb.Dimension6_ID = b.Dimension6_ID
where rb.DW_Current_Record = 1;

select 
		p.Dimension4_ID
	,	ts.Dimension5_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	ts.Dimension8_of_Service
	,	ts.Dimension11_Type
	,	ts.Scheduled_Date
	,	ts.Source_Last_Update_Date
	,	ts.Source_Created_Date
into #Dimension11
from #Dimension4 p
join [X].dimTreatmentSchedule ts on ts.Dimension4_ID = p.Dimension4_ID 
	and ts.DW_Current_Record = 1
	and ts.Dimension11_Type = 'Appointment 1'
	and ts.Dimension8_of_Service = 'Home'
	and ts.Scheduled_Date is NOT NULL
	and ts.Outcome IS NULL
	and ts.dimDimension1Key = p.dimDimension1Key
	and p.dimDimension5Key = ts.dimDimension5Key;   


/*	TypeM Dimension4s */
--SQL
update #Dimension4
set Dimension4_Category = 'TypeM' 
from  #Dimension4 p
join #ZepDimension3 c on c.Dimension4_ID = p.Dimension4_ID  
		and c.Dimension2_ID = p.Dimension2_ID
		and c.Dimension6_ID = p.Dimension6_ID
		and c.Dimension3_Status not in ('Completed', 'Cancelled')				
		and c.Dimension3_Record_Type = 'TypeM';

/* Related Adjective Dimension8 Data */
select distinct
		  rb.Dimension4_ID
		, sdrp.Dimension5_ID
		, rb.Dimension6_ID
		, rb.Dimension2_ID
		, sdrp.Dimension8_ID
		, sds.dimDimension8Key
		, sdrp.XYZ_Dimension8_ID
		, sdrp.XYZ_ID
		, sds.STATUS Dimension8_Status
		, sdrp.Type
		, sds.Dimension8_Name
		, sds.Postal_Address_ID
		, sds.Phone_Address_ID
into #relatedDimension8
from [X].dimDimension7 as sdrp
join #Dimension5 rb on rb.Dimension5_ID = sdrp.Dimension5_ID
join [X].dimDimension8 as sds on sds.Dimension8_ID = sdrp.Dimension8_ID 
	and sds.Status = 'Active' 
	and sds.DW_Current_Record = 1
where sdrp.STATUS = 'Active' 
	and sdrp.Type = 'Adjective'
	and sdrp.DW_Current_Record = 1;

	
/* Adjective Dimension8 Detail Data */
select  distinct 
			rs.Dimension5_ID
		,	rs.Dimension4_ID
		,	rs.Dimension2_ID
		,	rs.Dimension6_ID
		,	s.Dimension8_ID
		,	s.CRM_Source_ID
		,	s.Dimension8_Name
		,	g.Address_1
		,	g.Address_2
		,	g.City
		,	g.State_Code
		,	g.Postal_Code
		,	va.VIRTUAL_ADDRESS_VALUE as Dimension8_Phone
		,	rs.XYZ_ID
into #Dimension8
from #relatedDimension8 rs
join [X].dimDimension8 s on rs.Dimension8_ID = s.Dimension8_ID 
	and s.DW_Current_record = 1
join [X].[vw_dimGeography] g on s.Postal_Address_ID = g.Postal_Address_Id
	and g.DW_Current_Record = 1
left join [[X]_stg].[stg_dmp_virtual_address] as va on s.Phone_Address_ID = va.VIRTUAL_ADDRESS_ID
where 1=1
	and s.DW_Current_Record = 1;


	
/* All Dimension3/Dimension4 Data */

/*  Latest Closed CD Dimension3s */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LatestCompCD
from #Dimension4 p
join #ZepDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and c.Dimension2_ID = p.Dimension2_ID
	and c.Dimension6_ID = p.Dimension6_ID
	and c.Dimension3_Record_Type = 'TypeB'
	and c.Dimension3_Status = 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'TypeB'
						and d.Dimension3_Status = 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID
						);

/*  Latest Open CD Dimension3s */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LOCD
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'TypeB'
	and c.Dimension3_Status <> 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'TypeB'
						and d.Dimension3_Status <> 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID
						);



/*  First CD Dimension3s */
		select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
	,	c.Dimension3_Owner
into #MinCD
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and c.Dimension2_Id = p.Dimension2_ID
	and c.Dimension6_ID = p.Dimension6_ID
	and c.Dimension3_Record_Type in ('Type B')
	and c.Source_Created_Date in (select min(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type in ('Type B')
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID
						);
--SQL
update #Dimension4
set Support_Contact = CD1.Dimension3_Owner
from #Dimension4 p
join #MinCD CD1 on CD1.Dimension4_ID = p.Dimension4_ID 
	and CD1.Dimension2_ID = p.Dimension2_ID
	and CD1.Dimension6_ID = p.Dimension6_ID;

/*  Latest Closed PA and SubTypeA Dimension3s */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LatestCompPA
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'Type P'
	and c.Dimension3_Status = 'Completed'
	and c.Source_Created_Date in (select top 2 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'Type P'
						and d.Dimension3_Status = 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID, d.Dimension3_Sub_Type
						);

					
/*  Latest Open PA Dimension3s */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LOPA
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'Type P'
	and c.Dimension3_Status <> 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'Type P'
						and d.Dimension3_Status <> 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID
						);
						

/*  Latest Completed TypeT Dimension3 */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LatestCompTypeT
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'TypeT' 
	and c.Dimension3_Status = 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'TypeT'
						and d.Dimension3_Status = 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID, d.Dimension3_Sub_Type
						);

/*  Latest Completed TypeT Starter & Commercial Dimension3s */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LatestCompCS
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'TypeT' 
	and c.Dimension3_Sub_Type in ('SubType1', 'SubType2')
	and c.Dimension3_Status = 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_record_type = 'TypeT'
						and d.Dimension3_Sub_Type = 'SubType1'
						and d.Dimension3_Status = 'Completed'
						and d.Dimension4_ID = c.Dimension4_ID
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_id, d.Dimension2_ID, d.Dimension6_ID, d.Dimension3_Record_Type
						);

/*  Latest Open TypeT */

select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
into #LOTypeT
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type = 'TypeT' 
	and c.Dimension3_Status <> 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) as Source_Created_Date
						from #ZDimension3 d 
						where d.Dimension3_Record_Type = 'TypeT'
						and d.Dimension3_Status <> 'Completed'
						and d.Dimension4_id = c.Dimension4_id
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						group by d.Dimension4_ID, d.Dimension2_ID, d.Dimension6_ID
						);


/*  Current Dimension3  */
select	distinct
		p.Dimension4_ID
	,	p.Dimension2_ID
	,	p.Dimension6_ID
	,	c.Dimension3_ID
	,	c.Dimension3_Number
	,	c.Dimension3_Record_Type
	,	c.Dimension3_Sub_type
	,	c.Dimension3_Status
	,	c.TypeT_Task_Delivery_Date
	,	c.TypeTShipmentDate
	,	c.closed_on as Closed_Date
	,	c.Source_Created_Date
	,	c.Dimension8_ID
	,	p.Support_Contact
into #CurrentDimension3
from #Dimension4 p
join #ZDimension3 c on c.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = c.Dimension2_ID
	and p.Dimension6_ID = c.Dimension6_ID
	and c.Dimension3_Record_Type <> 'TypeM'
	and c.Dimension3_Status <> 'Completed'
	and c.Source_Created_Date in (select top 1 max(d.Source_Created_Date) 
						from #ZDimension3 d 
						where 
							d.Dimension3_Status <> 'Completed'
						and d.Dimension3_Record_type <> 'TypeM'
						and d.Dimension4_id = c.Dimension4_id
						and d.Dimension2_ID = c.Dimension2_ID
						and d.Dimension6_ID = c.Dimension6_ID
						);


/*       FINAL OUTPUT      */
/*        Dimension8 DATA        */
--Dimension8:
	select distinct
		rs.Dimension8_ID
	,	rs.dimDimension8Key
	,	s.Dimension8_Name as [Dimension8 Name]
	,	s.Address_1 as [Address 1]
	,	ISNULL(s.Address_2, ' ') as [Address 2]
	,	s.City 
	,	s.State_Code as State
	,	s.Postal_Code --as [Zip Code]
	,	s.Dimension8_Phone as [Phone]
	into #Dimension8Results
	from #Dimension5 rb
	join #relatedDimension8 rs on rb.Dimension5_ID = rs.Dimension5_ID
	join #Dimension8 s on s.Dimension8_ID = rs.Dimension8_ID
	join #Dimension4 p on p.Dimension4_ID = rb.Dimension4_ID
	group by rs.Dimension8_ID
	,	rs.dimDimension8Key
	,	s.Dimension8_Name
	,	s.Address_1
	,	s.Address_2
	,	s.City
	,	s.State_Code
	,	s.Postal_Code
	,	s.Dimension8_Phone;

--SQL
	update #Dimension8Results
	set Phone = SUBSTRING(Phone, 1, 3) + '-' +
		SUBSTRING(Phone, 4, 3) + '-' + 
		SUBSTRING(Phone, 7, 4);






	--Dimension8Reps:
/*  SalesRepToDimension8  */
select distinct
		s.*
	,	UPPER(sa.NTName) as USERNAME
into #sr1
from [X].dimDimension8UserAlignment ssra 
join #Dimension8Results s on s.dimDimension8Key = ssra.dimDimension8Key
join [X].dimUserTypeX sr on sr.dimUserTypeXKey = ssra.dimUserTypeXKey
	and sr.DW_Current_Record = 1
join [X].dimPortalSubscription ps on ps.Sales_Representative_ID = sr.Sales_Representative_ID
	and ps.DW_Current_Record = 1
join [X].vw_dimSectionAccess sa on sa.UserID = ps.User_Name
	and sa.Level_1 <> 'NO ACCESS'
	and sa.report_name = 'XXReportNameXX'
join [X].dimDimension1 c on c.dimDimension1Key = ssra.dimDimension1Key
	and c.Dimension1Name = 'Celgene'
	and c.DW_Current_Record = 1
where 1=1;

select distinct
		sr1.* 
	,	upper(sa.NTName) as USERNAME
into #sr2
from #Dimension8Results sr1
join [X].dimDimension8UserAlignment ssra on ssra.dimDimension8Key = sr1.dimDimension8Key
join #Dimension1Dimension2 c on c.dimDimension1Key = ssra.dimDimension1Key
join [X].dimUserTypeX sr on sr.dimUserTypeXKey = ssra.dimUserTypeXKey
	and sr.DW_Current_Record = 1
join [X].dimPortalSubscription ps on ps.Sales_Representative_ID = sr.Sales_Representative_ID
	and ps.DW_Current_Record = 1
join [X].vw_dimSectionAccess sa on sa.UserID = ps.User_Name
	and sa.Level_1 <> 'NO ACCESS'
	and sa.report_name = 'XXReportNameXX'


union 

select distinct
		sr1.*
	, 	UPPER(other.NTNAME) as USERNAME
from [X].vw_dimSectionAccess other
left join #Dimension8Results sr1 on sr1.dimDimension8Key is not null
where 1=1
and other.Level_1 <> 'NO ACCESS'
and (
		(other.Role = 'Role1' and other.report_name = 'XXReportNameXX' and other.Dimension1 = @Dimension1)
	or
		(other.Role = 'Super User' and other.report_name in ('XXReportNameXX', '*') and other.Dimension1 in (@Dimension1, '*'))
	or
		(other.Role like '%Role 2%' 
			and other.IsDimension8Aligned = 0 
			and other.report_name = 'XXReportNameXX' 
			and other.Dimension1 = @Dimension1)
)

select * from #sr2


/*         Dimension4 Dimension3 DATA           */
--Dimension4Dimension3:
select distinct
		p.Dimension4_Category as [Dimension4 Category]
	,	p.Dimension1
	,	p.Dimension2
	,	rb.Dimension6
	,	p.Dimension4_ID 
	,	p.CRM_Dimension4_ID as [Hub ID]
	,	CONCAT(p.First_Name, ' ', p.Last_Name) as [Dimension4 Name]
	,	CONVERT(varchar, p.Date_Of_Birth, 1) as [DOB]
	,	pref.Dimension10 as [Dimension_10]
	,	Dimension3
			when t.Dimension11_Type is NOT NULL then 'Type_O1'
			when cc.Dimension3_Record_Type = 'TypeB' and cc.Dimension3_Sub_Type = 'SubTypeB1' then 'Type_B1'
			when cc.Dimension3_Record_Type = 'TypeB' and cc.Dimension3_Sub_Type = 'SubTypeB2' then 'Type_B2'
			when cc.Dimension3_Record_Type = 'TypeP' and cc.Dimension3_Sub_Type = 'SubTypeP1' then 'Type_P1'
			when cc.Dimension3_Record_Type = 'TypeP' and cc.Dimension3_Sub_Type = 'SubTypeP2' then 'Type_P2'
			when cc.Dimension3_Record_Type = 'TypeP' and cc.Dimension3_Sub_Type = 'SubTypeP3' then 'Type_P3'
			when cc.Dimension3_Record_Type = 'TypeT' and cc.Dimension3_Sub_Type = 'SubTypeT1' then 'Type_T1'
			when cc.Dimension3_Record_Type = 'TypeT' and cc.Dimension3_Sub_Type = 'SubTypeT2' then 'Type_T2'
			when cc.Dimension3_Record_Type = 'TypeT' and cc.Dimension3_Sub_Type = 'SubTypeT2' then 'Type_T2'
			else cc.Dimension3_Record_Type
		End As [Current Dimension4 Step]
	,	cc.Dimension3_Sub_Type
	,	Dimension3
			when t.Dimension11_Type is not null then DATEDIFF(dd, t.Source_Created_Date, t.Scheduled_Date)
			else DATEDIFF(dd, cc.Source_Created_Date, GETDATE()) 
		end as [Days in Step]
	,	cc.Dimension3_Status as Curr_Dimension3_Status
	,	Dimension3
			when opa.Dimension3_Record_Type IS NOT NULL then 'Label 1'
			when oApp.Dimension3_Record_Type IS NOT NULL then 'Label 2'
			else NULL
		end as [XYZ Action Needed]
	,	CONVERT(varchar, CD1.Source_Created_Date, 1) as [XX Field Submission]  
	,	Dimension3
			when cc.Dimension3_Record_Type = 'TypeB' then 'Label 3'
			when oCD.Dimension3_Number IS NOT NULL then 'Label 3'
			else CONVERT(varchar, lCD.Closed_Date, 1) 
		end as CD
	,	Dimension3
			when cc.Dimension3_Record_Type = 'TypeP' and cc.Dimension3_Sub_Type <> 'Subtype1' then 'Label 3'
			when opa.Source_Created_Date IS NOT NULL then 'Label 3'
			else convert(varchar, lpa.Closed_Date, 1)
		End As PA
	,	Dimension3
			when cc.Dimension3_record_Type = 'TypeP' and cc.Dimension3_Sub_Type = 'Subtype1' then 'In Process'
			when oApp.Source_Created_Date IS NOT NULL then 'Label3'
			else convert(varchar, lApp.Closed_Date, 1)
		end as SubTypeA
	,	convert(varchar, t.Scheduled_Date, 1) as [BA Scheduled]
	,	Dimension3
			when cc.Dimension3_record_type = 'TypeT' then 'Label3'
			when otr.Source_Created_Date IS NOT NULL then 'Label3'
			else convert(varchar, ltr.Closed_Date, 1)
		end as [TypeTd to SP]
	,	Dimension3
			when CD1.Source_Created_Date < '2021-03-01' then convert(varchar, st.TypeTShipmentDate, 1)
			when CD1.Source_Created_Date >= '2021-03-01' then convert(varchar, com.TypeTShipmentDate, 1)
			else NULL
		end as [Comm.Shipped]
	,	rs.Dimension8_ID
	,	p.XX_Field as [XX Field S Contact]
from #Dimension4 p
join #CurrentDimension3 cc on cc.Dimension4_ID = p.Dimension4_ID
	and p.Dimension2_ID = cc.Dimension2_ID
	and p.Dimension6_ID = cc.Dimension6_ID
join #Dimension5 rb on rb.Dimension4_ID = p.Dimension4_ID 
	and rb.Dimension2_ID = p.Dimension2_ID 
	and rb.Dimension6_ID = rb.Dimension6_ID
left join #MinCD CD1 on CD1.Dimension4_ID = cc.Dimension4_ID
	and CD1.Dimension2_ID = cc.Dimension2_ID
	and CD1.Dimension6_ID = cc.Dimension6_ID
left join #LatestCompCD lCD on lCD.Dimension4_ID = cc.Dimension4_ID
	and lCD.Dimension2_ID = cc.Dimension2_ID
	and lCD.Dimension6_ID = cc.Dimension6_ID
left join #LatestCompPA lPA on lPA.Dimension4_ID = cc.Dimension4_ID
	and lPA.Dimension2_ID = cc.Dimension2_ID
	and lPA.Dimension6_ID = cc.Dimension6_ID
	and lPA.Dimension3_Sub_Type in ('SubType1', 'SubType2')
left join #LatestCompPA lApp on lApp.Dimension4_ID = cc.Dimension4_ID
	and lApp.Dimension2_ID = cc.Dimension2_ID
	and lApp.Dimension6_ID = cc.Dimension6_ID
	and lApp.Dimension3_Sub_Type = 'SubTypeA'
left join #LatestCompTypeT ltr on ltr.Dimension4_ID = cc.Dimension4_ID
	and ltr.Dimension2_ID = cc.Dimension2_ID
	and ltr.Dimension6_ID = cc.Dimension6_ID
left join #LOCD oCD on oCD.Dimension4_ID = cc.Dimension4_ID
	and oCD.Dimension2_ID = cc.Dimension2_ID
	and oCD.Dimension6_ID = cc.Dimension6_ID
left join #LOPA oPA on opa.Dimension4_ID = cc.Dimension4_ID
	and oPA.Dimension2_ID = cc.Dimension2_ID
	and oPA.Dimension6_ID = cc.Dimension6_ID
	and oPA.Dimension3_Sub_Type in ('SubType1', 'SubType2')
left join #LOPA oApp on oApp.Dimension4_ID = cc.Dimension4_ID
	and oApp.Dimension2_ID = cc.Dimension2_ID
	and oApp.Dimension6_ID = cc.Dimension6_ID
	and oApp.Dimension3_Sub_Type = 'SubTypeA'
left join #Dimension11 t on t.Dimension4_ID = cc.Dimension4_ID
	and t.Dimension2_ID = cc.Dimension2_ID
	and t.Dimension6_ID = cc.Dimension6_ID
left join #LOTypeT otr on otr.Dimension4_ID = cc.Dimension4_ID
	and otr.Dimension2_ID = cc.Dimension2_ID
	and otr.Dimension6_ID = cc.Dimension6_ID
left join #LatestCompCS st on st.Dimension4_ID = cc.Dimension4_ID
	and st.Dimension2_ID = cc.Dimension2_ID
	and st.Dimension6_ID = cc.Dimension6_ID
	and st.Dimension3_Sub_Type = 'SubType1'
left join #LatestCompCS com on com.Dimension4_ID = cc.Dimension4_ID
	and com.Dimension2_ID = cc.Dimension2_ID
	and com.Dimension6_ID = cc.Dimension6_ID
	and com.Dimension3_Sub_Type = 'SubType2'
join #relatedDimension8 rs on rs.Dimension4_ID = p.Dimension4_ID
	and rs.Dimension2_ID = cc.Dimension2_ID
	and rs.Dimension6_ID = cc.Dimension6_ID
left join [X].dimConsentOptPreference pref on pref.Dimension4_ID = p.Dimension4_ID
	and pref.Dimension2_ID = p.Dimension2_ID
	and pref.Record_Type = 'Dimension4 Preference'
	and pref.DW_Current_Record = 1
order by p.Dimension4_ID;

--Store Site into $(QVDPath)\Dim_DispDim1.qvd;
--Store PatientCase into $(QVDPath)\Dim_PDim2.qvd;
--Store SiteReps into $(QVDPath)\Dim_Dim3.qvd;

--DROP TABLE ABC;
--DROP TABLE DEF;
--DROP TABLE GHI;
