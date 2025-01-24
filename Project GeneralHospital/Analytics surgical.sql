Select * 
--PIn.[Master Patient ID], [Patient Ethnicity], [Patient Country], [Surgical DRG Description], [Surgical Total Cost], [Surgical Total Profit]
from dbo.PatientInternal as PIn
Left join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
Left Join dbo.SurgicalEncounters as SE 
ON PIn.[Surgery ID] = SE.[Surgery ID]
where PIn.[Surgery ID] is NOT NULL


-- Record duoc ghi nhan tu thang 2/2016 den thang 4/2017
select YEAR([Patient Admission Datetime]), MONTH([Patient Admission Datetime]) 
, count(ED.[Patient Encounter ID])
from dbo.Encounters as E
Left join dbo.EncounterDetails as ED
ON E.[Patient Encounter ID] = ED.[Patient Encounter ID]
Group by YEAR([Patient Admission Datetime]), MONTH([Patient Admission Datetime]) 
Order by YEAR([Patient Admission Datetime]) ASC, MONTH([Patient Admission Datetime]) ASC 

select *
from dbo.Encounters as E
Left join dbo.EncounterDetails as ED
ON E.[Patient Encounter ID] = ED.[Patient Encounter ID]


-- 7,096 [Master Patient ID] 
select *
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Recorded'
when Pa.[Master Patient ID] != Se.[Master Patient ID] then 'Patient_Unrecorded'
END as Classify_patient
from dbo.Patients as Pa
Full join dbo.PatientInternal as PaI
ON Pa.[Master Patient ID] = PaI.[Master Patient ID]
Full join dbo.SurgicalEncounters as Se 
On PaI.[Surgery ID] = Se.[Surgery ID]



where PIn.[Surgery ID] is NOT NULL


-- 6,061 [Master Patient ID]
select count(distinct [Master Patient ID])
from dbo.SurgicalEncounters
where [Master Patient ID] <= 102574
Order by  [Master Patient ID] ASC
 

-- 3,494 [Master Patient ID]
select *
from dbo.QualityMeasureData



---- Classify patient
with table_join as (
Select  PIn.[Master Patient ID] AS PIn_MasterPatientID,
        Pa.[Master Patient ID] AS Pa_MasterPatientID,
        SE.[Master Patient ID] AS SE_MasterPatientID
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_group as( 
select Classify_patient_record
, count(distinct case when Classify_patient_record = 'Patient_Surgical_Recorded' then Pa_MasterPatientID end) as Num_Patient_Surgical_Recorded
, count(distinct case when Classify_patient_record = 'Patient_Surgical_Unrecorded' then SE_MasterPatientID end) as Num_Patient_Surgical_Unrecorded
, count(distinct case when Classify_patient_record = 'Patient_Unsurgical_Recorded' then Pa_MasterPatientID end) as Num_Patient_Unsurgical
, count(distinct case when Classify_patient_record != 'Patient_Surgical_Unrecorded' then Pa_MasterPatientID end) as Total_num_patient_record
from table_join
Group by Classify_patient_record)

, table_concat as (
select *
, Total_num_patient = Num_Patient_Surgical_Recorded + Num_Patient_Surgical_Unrecorded + Num_Patient_Unsurgical
, (select SUM(Total_num_patient_record) from table_group) as Overall_total_num_patient_record
,  CONCAT_WS(' / ', Num_Patient_Surgical_Recorded + Num_Patient_Surgical_Unrecorded + Num_Patient_Unsurgical, (select SUM(Total_num_patient_record) from table_group)) as Number_Total_Patient_Recorded
from table_group   )

select Classify_patient_record, Total_num_patient
, case when Total_num_patient IN (5776, 1320) THEN '7096'
ELSE ' ' END as Total_Patient_System
, case when Total_num_patient IN (5776, 285) THEN '6061'
ELSE ' ' END as Total_Patient_Surgical
/*, case when Classify_patient_record = 'Patient_Surgical_Unrecorded' then Replace(Number_Total_Patient_Recorded, Number_Total_Patient_Recorded, Num_Patient_Surgical_Unrecorded )
ELSE Number_Total_Patient_Recorded
END as Number_Total_Patient_Recorded */
from table_concat


--- check coi 285 benh nhan chua duoc record do thuong thi ly do vi sao? maybe: thong tin, tinh trang benh, 143 bệnh nhân đã nhập viện trên 2 lần
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_group as (
select *
, ROW_NUMBER() OVER (partition by SE_MasterPatientID Order by [Surgical Admission Date] ASC) as rn_date_admiss
from table_join
where SE_MasterPatientID IS NOT NULL )

, table_rn as (
select [Surgical Admission Type]
, CONCAT_WS(' / ', COUNT(SE_MasterPatientID), (select COUNT(SE_MasterPatientID) from table_group where Classify_patient_record = 'Patient_Surgical_Unrecorded')) as NumTotal_Patient_Admiss_AboveOneTime
, (select COUNT(distinct SE_MasterPatientID) from table_group where Classify_patient_record = 'Patient_Surgical_Unrecorded') as Total_patient_All_Time
from table_group
where Classify_patient_record = 'Patient_Surgical_Unrecorded'
GROUP by [Surgical Admission Type] )

, table_groupby as (
select  [Surgical Admission Type], [Surgical Admission Desecription]
, count(SE_MasterPatientID) as Num_patient_addmis
from table_join
where Classify_patient_record = 'Patient_Surgical_Unrecorded'
Group by [Surgical Admission Type], [Surgical Admission Desecription]  )

, table_above1 as (
select [Surgical Admission Type]
, CONCAT_WS(' / ', COUNT(SE_MasterPatientID), (select COUNT(SE_MasterPatientID) from table_group where Classify_patient_record = 'Patient_Surgical_Unrecorded' and rn_date_admiss > 1 )) as NumTotal_Patient_Admiss_AboveOneTime
, (select COUNT(SE_MasterPatientID) from table_group where Classify_patient_record = 'Patient_Surgical_Unrecorded' and rn_date_admiss > 1 ) as Total_patient_Above_1_Time
from table_group
where Classify_patient_record = 'Patient_Surgical_Unrecorded' and rn_date_admiss > 1 
GROUP by [Surgical Admission Type] )

select t1.[Surgical Admission Type], t1.NumTotal_Patient_Admiss_AboveOneTime, Total_patient_Above_1_Time, Total_patient_All_Time
, format(cast(Total_patient_Above_1_Time as decimal) / Total_patient_All_Time, 'p') as Pct_Patient_above_1_time
from table_above1 as t1
Left Join table_rn as rn
On t1.[Surgical Admission Type] = rn.[Surgical Admission Type]



----- kiem tra profit and cost theo thoi gian ngay nhap vien
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_calculate as (
select YEAR([Surgical Admission Date]) as [Year], MONTH([Surgical Admission Date]) as [Month]
, COUNT(SE_MasterPatientID) as Num_patient
, Cast(SUM([Surgical Total Cost]) as decimal(10,2)) as Total_cost
, Cast(SUM([Surgical Total Profit]) as decimal(10,2)) as Total_profit
, Cast(SUM([Surgical Total Cost]) as decimal(10,2)) + Cast(SUM([Surgical Total Profit]) as decimal(10,2)) as Total_revenue
from table_join
where Classify_patient_record != 'Patient_Unsurgical_Recorded' and YEAR([Surgical Admission Date]) = 2016
Group by YEAR([Surgical Admission Date]), MONTH([Surgical Admission Date]) )

select [Year], [Month], Num_patient
, Convert(varchar(20), Total_revenue) + ' usd' as Total_revenue
, Convert(varchar(20), cast((select avg(Total_revenue) from table_calculate) as decimal(10,2))) + ' usd' as Mean_revenue
, Case when Total_revenue <= cast((select avg(Total_revenue) from table_calculate) as decimal(10,2)) THEN 'Under_mean_revenue'
		ELSE 'Above_mean_revenue'
		END as Segment_revenue
from table_calculate

----------------------Check profit của năm này

with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_calculate as (
select YEAR([Surgical Admission Date]) as [Year], MONTH([Surgical Admission Date]) as [Month]
, COUNT(SE_MasterPatientID) as Num_patient
, Cast(SUM([Surgical Total Cost]) as decimal(10,2)) as Total_cost
, Cast(SUM([Surgical Total Profit]) as decimal(10,2)) as Total_profit
, Cast(SUM([Surgical Total Cost]) as decimal(10,2)) + Cast(SUM([Surgical Total Profit]) as decimal(10,2)) as Total_revenue
from table_join
where Classify_patient_record != 'Patient_Unsurgical_Recorded' and YEAR([Surgical Admission Date]) = 2017
Group by YEAR([Surgical Admission Date]), MONTH([Surgical Admission Date]) )

select [Year], [Month], Num_patient, Total_revenue
, cast((select avg(Total_revenue) from table_calculate) as decimal(10,2)) as Mean_revenue
, Case when Total_revenue <= cast((select avg(Total_revenue) from table_calculate) as decimal(10,2)) THEN 'Under_mean_revenue'
		ELSE 'Above_mean_revenue'
		END as Segment_revenue
from table_calculate

----------- Check Num_patient 2016 
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_count as (
select YEAR([Surgical Admission Date]) [Year], MONTH([Surgical Admission Date]) as [Month]
, Count(SE_MasterPatientID) as Num_patient
from table_join
where YEAR([Surgical Admission Date]) = 2017 
GROUP BY YEAR([Surgical Admission Date]), MONTH([Surgical Admission Date]))

Select *
, rank() over (order by Num_patient DESC) as rank_patient
from table_count
Order by [Month] ASC


-------- PIVOT table ra thang 4,5,6,7,8,9,10 nam 2016 
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, pivot_data AS (
    SELECT 
        MONTH([Surgical Admission Date]) AS [Month], 
        [Surgical Admission Type], 
        COUNT(SE_MasterPatientID) AS Num_patient
    FROM table_join
    WHERE 
        YEAR([Surgical Admission Date]) = 2016 
        AND MONTH([Surgical Admission Date]) BETWEEN 4 AND 10
    GROUP BY 
        MONTH([Surgical Admission Date]), 
        [Surgical Admission Type]
)

SELECT 
    [Surgical Admission Type] AS Admission_Type,
	ISNULL([4], 0) AS [April],
    ISNULL([5], 0) AS [May],
    ISNULL([6], 0) AS [June],
    ISNULL([7], 0) AS [July],
    ISNULL([8], 0) AS [August],
    ISNULL([9], 0) AS [September],
    ISNULL([10], 0) AS [October]
FROM 
    pivot_data
PIVOT (
    SUM(Num_patient)
    FOR [Month] IN ([4], [5], [6], [7], [8], [9], [10])
) AS pvt
ORDER BY 
    CASE 
        WHEN [Surgical Admission Type] = 'Elective' THEN 1
        WHEN [Surgical Admission Type] = 'Emergency' THEN 2
        WHEN [Surgical Admission Type] = 'Maternity' THEN 3
        WHEN [Surgical Admission Type] = 'Other' THEN 4
        ELSE 5
    END;

---- Tìm xem những bệnh nhân thuộc loại nhập viện vào sẽ có trung bình liệu trình điều trị lâu nhất
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_group as (
select *
, ROW_NUMBER() OVER (partition by SE_MasterPatientID Order by [Surgical Admission Date] ASC) as rn_date_admiss
from table_join
where SE_MasterPatientID IS NOT NULL )

, table_avg as ( 
select *
, MAX(rn_date_admiss) over (partition by SE_MasterPatientID) as Num_treatment_patient
from table_group )

, table_group_avg as (
select [Surgical Admission Type]
, Convert(varchar(20), Cast(AVG(Cast(Num_treatment_patient as Decimal)) as decimal(10,2))) + ' Day' as Avg_treatment_patient_each_type_admiss
from table_avg
Group by [Surgical Admission Type] )

select *
, Rank() over(order by Avg_treatment_patient_each_type_admiss DESC) as rank_treatment
from table_group_avg


-------- PIVOT table ra thang 1,2,3 nam 2017

with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, pivot_data AS (
    SELECT 
        MONTH([Surgical Admission Date]) AS [Month], 
        [Surgical Admission Type], 
        COUNT(SE_MasterPatientID) AS Num_patient
    FROM table_join
    WHERE 
        YEAR([Surgical Admission Date]) = 2017
        AND MONTH([Surgical Admission Date]) BETWEEN 1 AND 3
    GROUP BY 
        MONTH([Surgical Admission Date]), 
        [Surgical Admission Type]
)

SELECT 
    [Surgical Admission Type] AS Admission_Type,
	ISNULL([1], 0) AS [January],
    ISNULL([2], 0) AS [February],
    ISNULL([3], 0) AS [March]
FROM 
    pivot_data
PIVOT (
    SUM(Num_patient)
    FOR [Month] IN ([1], [2], [3])
) AS pvt
ORDER BY 
    CASE 
        WHEN [Surgical Admission Type] = 'Elective' THEN 1
        WHEN [Surgical Admission Type] = 'Emergency' THEN 2
        WHEN [Surgical Admission Type] = 'Maternity' THEN 3
        WHEN [Surgical Admission Type] = 'Other' THEN 4
        ELSE 5
    END;

---------- Theo dõi chỉ số cost và profit theo thời gian 

with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_group as (
select YEAR([Surgical Admission Date]) as [Year], MONTH([Surgical Admission Date]) as [Month]
, COUNT(SE_MasterPatientID) as Num_patient
, Cast(SUM([Surgical Total Cost]) as decimal(10,2)) as Total_cost_USD
, Cast(SUM([Surgical Total Profit]) as decimal(10,2)) as Total_profit_USD
from table_join
where YEAR([Surgical Admission Date]) = 2016
Group by YEAR([Surgical Admission Date]), MONTH([Surgical Admission Date]) )

select [Year], [Month], Num_patient
, Convert(varchar(20), Total_cost_USD) + ' usd' as Total_cost
, Convert(varchar(20), Total_profit_USD) + ' usd' as Total_profit
, RANK() Over (order by Total_cost_USD DESC) as rank_cost
, RANK() Over (order by Total_profit_USD DESC) as rank_profit
from table_group
Order by [Month]  ASC

---- check profit + hay - cua thang 8 va thang 5 nam 2016 
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_month_5_6 as (
select *
from table_join
where YEAR([Surgical Admission Date]) = 2016 and MONTH([Surgical Admission Date]) IN(5))

, table_segment as (
Select *
, AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) as AVG_Profit_Each_Patient
, case when AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) <= 0 THEN 'Negative_profit'
 when AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) > 0  THEN 'Positive_profit' 
END as segment_profit 
from table_month_5_6 
where SE_MasterPatientID IS NOT NULL )

, table_calculate as (
select MONTH([Surgical Admission Date]) as [Month], segment_profit
, count( SE_MasterPatientID) as Num_patient
, (select count( SE_MasterPatientID) from table_segment) as total_patient_mont_5
, Format (cast (count( SE_MasterPatientID) as decimal) / (select count( SE_MasterPatientID) from table_segment), 'p') as Pct_patient
from table_segment
Group by MONTH([Surgical Admission Date]) , segment_profit )

select MONTH([Surgical Admission Date]) as [Month], segment_profit
,  CONVERT(VARCHAR(20), CAST(SUM([Surgical Total Profit]) AS DECIMAL(10,2))) + ' usd' AS Total_profit_patient
from table_segment
Group by MONTH([Surgical Admission Date]), segment_profit


------ check tháng 5/2016 profit của mỗi bệnh nhân
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )


select YEAR([Surgical Admission Date]) as [Year], MONTH([Surgical Admission Date]) as [Month]
, COUNT(SE_MasterPatientID) as Num_patient_month
from table_join
where [Surgical Total Profit] <= 0
Group by YEAR([Surgical Admission Date]), MONTH([Surgical Admission Date]) 
Order by YEAR([Surgical Admission Date]) ASC, MONTH([Surgical Admission Date]) ASC

---- tính số người âmm profit và dương prodit 
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_segment as (
Select *
, AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) as AVG_Profit_Each_Patient
, case when AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) <= 0 THEN 'Negative_profit'
 when AVG([Surgical Total Profit]) over (partition by SE_MasterPatientID) > 0  THEN 'Positive_profit' 
END as segment_profit 
from table_join 
where SE_MasterPatientID IS NOT NULL  )

select segment_profit
, CONCAT_WS('/', count(distinct SE_MasterPatientID), (select  count(distinct SE_MasterPatientID) from table_segment)) as NumTotal_patient_profit
, Format(cast(count(distinct SE_MasterPatientID) as decimal) / (select  count(distinct SE_MasterPatientID) from table_segment), 'p') as pct_patient
, CONVERT (NVarchar(50), SUM(AVG_Profit_Each_Patient)) + ' USD' as Avg_profit
from table_segment
Group by segment_profit

------

select segment_profit
, count(SE_MasterPatientID)

from table_segment
Where segment_profit IS NOT NULL
GROUP BY segment_profit


select segment_profit
, CONCAT_WS (' / ', count(distinct SE_MasterPatientID), (select count(distinct SE_MasterPatientID) from table_segment)) as Num_total_Patient_segment_profit
, Format(Cast(count(distinct SE_MasterPatientID) as Decimal) / (select count(distinct SE_MasterPatientID) from table_segment), 'p') as Pct_Patient_profit
from table_segment
Group by segment_profit


---- Tính trung bình ngày nhập viện trên mỗi bệnh nhân và loại nhập viện đó là gì
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical LOS], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

, table_avg_patient as (
select *
, Cast(AVG(Cast([Surgical LOS] as FLOAT)) Over (partition by SE_MasterPatientID)  as decimal(10,2)) as AVG_LOS
from table_join
where SE_MasterPatientID IS NOT NULL )

select [Surgical Admission Type]
, CONVERT(nvarchar(50), Cast(AVG(AVG_LOS) as decimal(10,2) )) + ' Day' as Avg_LOS_Surgical_Type
--, STRING_AGG([Surgical Admission Type], ' ,') WITHIN GROUP (Order by [Surgical Admission Type] ASC)
, rank() over (order by AVG(AVG_LOS) DESC) as Rank_LOS
from table_avg_patient
Group by [Surgical Admission Type]


------ Check kỹ mỗi loại đó là gì (emergency and other)
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Surgical Admission Date], [Surgical Discharge Date], [Surgical LOS], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

--, table_avg_patient as (
select [Surgical Admission Type],  [Surgical Admission Desecription] 
from table_join
where SE_MasterPatientID IS NOT NULL and [Surgical Admission Type] ='Emergency'
GROUP BY [Surgical Admission Type],  [Surgical Admission Desecription] 
 )


------ Patient categories
with table_join as (
Select  
 	PIn.[Master Patient ID] AS PIn_MasterPatientID,
    Pa.[Master Patient ID] AS Pa_MasterPatientID,
    SE.[Master Patient ID] AS SE_MasterPatientID,
	[Patient County], [Patient Gender], [Patient DOB], [Patient Ethnicity], [Surgical Admission Date], [Surgical Discharge Date], [Surgical DRG Description], [Surgical Type], [Surgical Total Cost], [Surgical Total Profit], [Surgical Admission Type], [Surgical Admission Desecription]
, Case when Pa.[Master Patient ID] = Se.[Master Patient ID] then 'Patient_Surgical_Recorded'
  when Pa.[Master Patient ID] is NULL then 'Patient_Surgical_Unrecorded'
  when SE.[Master Patient ID] is NULL then 'Patient_Unsurgical_Recorded'
END as Classify_patient_record
from dbo.PatientInternal as PIn
FULL join Patients as Pa
On Pa.[Master Patient ID] = PIn.[Master Patient ID]
FULL Join dbo.SurgicalEncounters as SE 
ON PIn.[Master Patient ID] = SE.[Master Patient ID] )

select * 
--, CAST(CONVERT(datetime, [Patient DOB], 101) AS date) AS Patient_DOB_Formatted

from table_join
WHERE ISDATE([Patient DOB]) = 0