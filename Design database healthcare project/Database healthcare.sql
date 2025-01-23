USE HealthCare

CREATE DATABASE HealthCare;

Create table Hospitalization (
	HospitalizationID INT NOT NULL PRIMARY KEY,
	RoomID INT FOREIGN KEY REFERENCES Room(RoomID),
	CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
	NurseID INT FOREIGN KEY REFERENCES Nurse(NurseID),
	Start_Date Datetime,
	End_Date Datetime, 
	Status varchar(10),
	Modified_date Datetime,
	Reason_modified varchar(20),
	Appointment INT,
	Total_Appointment INT )

Create table Customer (
	CustomerID INT NOT NULL PRIMARY KEY,
	Name_patient varchar(50),
	Phone INT,
	Age INT,
	ContactID INT FOREIGN KEY REFERENCES Contact(ContactID),
	NurseID INT FOREIGN KEY REFERENCES Nurse(NurseID), 
	PathologyID INT FOREIGN KEY REFERENCES Pathology(PathologyID), 
	RoomID INT FOREIGN KEY REFERENCES Room(RoomID) )
	
Create table Service (
	ServiceID INT NOT NULL PRIMARY KEY,
	Service_Type varchar(50),
	Description_Service varchar(50) )

Create table Department (
	DeparmentID INT NOT NULL PRIMARY KEY,
	Name_Deparment varchar(50) )

Create table Contact (
	ContactID INT NOT NULL PRIMARY KEY,
	Name_contact varchar(50), 
	Phone_contact INT )

Create table InsuranceCompany (
	CompanyID INT NOT NULL PRIMARY KEY,
	Name_company varchar(50), 
	Address varchar(50),
	Phone INT )

create table Pathology (
	PathologyID INT NOT NULL PRIMARY KEY,
	Name_Pathology varchar(50),
	Description varchar(50) )

Create table Nurse (
	NurseID INT NOT NULL PRIMARY KEY,
	Name_nurse varchar(50),
	DoctorID INT FOREIGN KEY REFERENCES Doctor(DoctorID) )

Create table Doctor (
	DoctorID INT NOT NULL PRIMARY KEY,
	Name_doctor varchar(50),
	PathologyID INT FOREIGN KEY REFERENCES Pathology(PathologyID),
	DepartmentID INT FOREIGN KEY REFERENCES Department(DeparmentID) )

Create table Room (
	RoomID INT NOT NULL PRIMARY KEY,
	Room_Type varchar(50),
	Room_number INT,
	SerivceID INT FOREIGN KEY REFERENCES Service(ServiceID), 
	DepartmentID INT FOREIGN KEY REFERENCES Department(DeparmentID) )

create table Insurance (
	InsuranceID INT NOT NULL PRIMARY KEY,
	Name_insurance varchar(50),
	Insurance_level varchar(50),
	CompanyID INT FOREIGN KEY REFERENCES InsuranceCompany(CompanyID),
	CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID))

TRUNCATE TABLE InsuranceCompany;

select *
from InsuranceCompany

INSERT INTO Insurance (InsuranceID, Name_insurance, Insurance_level, CompanyID, CustomerID)
VALUES
(1, 'Blue Cross Blue', 'Co ban', 7, 2),
(2, 'UnitedHealthcare', 'Nang cao', 7, 7),
(3, 'Aetna', 'Trung binh', 7, 4),
(4, 'Cigna', 'Trung Binh', 2, 2),
(5, 'Humana', 'Co Ban', 4, 4),
(6, 'Kaiser Permane', 'Co Ban', 3, 3),
(7, 'Anthem', 'Nang cao', 4, 6);

INSERT INTO InsuranceCompany (CompanyID, Name_company, Address, Phone)
VALUES
(1, 'Allianz', 'info@allianz-fak', 493012345678),
(2, 'AXA', 'contact@axa-fak', 33123456789),
(3, 'Prudential', 'support@prudential', 442012345678),
(4, 'MetLife', 'customer@metlife', 12123456789),
(5, 'Zurich Insurance', 'service@zurich', 41441234567),
(6, 'AIG - American', 'inquiries@aig-fak', 16469876543),
(7, 'Generali', 'help@generali-fak', 39062345678);

INSERT INTO Pathology (PathologyID, Name_Pathology, Description)
VALUES
(1, 'Pneumonia', 'Cough, fever, difficulty breathing, chest pain.'),
(2, 'Heart attack', 'Chest pain, shortness of breath, sweating, nausea.'),
(3, 'Stroke', 'Sudden weakness, numbness, confusion, trouble speaking.'),
(4, 'Appendicitis', 'Abdominal pain, nausea, vomiting, loss of appetite.'),
(5, 'Sepsis', 'High fever, rapid heart rate, confusion, low blood pressure'),
(6, 'Gastrointestinal bleeding', 'Vomiting blood, black stools, abdominal pain, weakness.'),
(7, 'Kidney failure', 'Swelling, fatigue, decreased urine output, nausea.');

INSERT INTO Department (DeparmentID, Name_Deparment)
VALUES
(1, 'Emergency Department'),
(2, 'Surgery Department'),
(3, 'Pediatrics Department'),
(4, 'Internal Medicine Department'),
(5, 'Obstetrics and Gynecology Department'),
(6, 'Radiology Department'),
(7, 'Oncology Department');

INSERT INTO Service (ServiceID, Service_Type, Description_Service)
VALUES
(1, 'Basic Care Package','Room with Air Conditioning, Standard Hospital Gown, Vital Signs Monitoring, Medication Administration'),
(2, 'Intermediate Care Package', 'Private or Semi-private Room, Enhanced Nutrition Plan, Regular Consultations with Doctors, Physical Therapy Sessions'),
(3, 'Advanced Care Package', 'Luxurious Private Room, Psychological Support, 24/7 Nurse Assistance');

INSERT INTO Doctor (DoctorID, Name_doctor, PathologyID, DepartmentID )
VALUES
(1, 'Dr. Emily Clark', 4, 4 ),
(2, 'Dr. John Roberts', 6, 4),
(3, 'Dr. Sarah Thompson', 7, 5),
(4, 'Dr. Michael Lee', 7, 2 ),
(5, 'Dr. Jessica Wilson', 4, 1),
(6, 'Dr. David Harris', 1, 1),
(7, 'Dr. Linda Garcia', 3, 7);

INSERT INTO Room  (RoomID, Room_Type, Room_number, SerivceID, DepartmentID )
VALUES
(1, 'Co ban', 101, 1, 1 ),
(2, 'Cao Cap', 102, 3, 1),
(3, 'Trung binh', 103, 2, 1),
(4, 'Trung binh', 104, 2,4 ),
(5, 'Co ban', 105, 1, 4),
(6, 'Co ban', 106, 1, 5),
(7, 'Cao Cap ', 107, 3, 5);


INSERT INTO Nurse (NurseID, Name_nurse, DoctorID)
VALUES
(1, 'Alice Johnson', 2),
(2, 'Michael Smith', 4),
(3, 'Sophia Davis', 4),
(4, 'James Brown', 3),
(5, 'Zurich Emma Wilson', 5),
(6, 'David Taylor', 6),
(7, 'Olivia Martinez', 6);

INSERT INTO Insurance (InsuranceID, Name_insurance, Insurance_level, CompanyID, CustomerID)
VALUES
(1, 'Blue Cross Blue Shield', 'Co ban', 7, 2),
(2, 'UnitedHealthcare', 'Nang cao', 7, 7),
(3, 'Aetna','Trung binh', 7, 4),
(4, 'Cigna', 'Trung Binh', 2, 2),
(5, 'Humana', 'Co Ban', 4, 4),
(6, 'Kaiser Permanente', 'Co Ban', 3, 6),
(7, 'Anthem', 'Nang cao', 4, 6);

INSERT INTO Customer (CustomerID, Name_patient, Phone, Age, ContactID, NurseID, PathologyID, RoomID)
VALUES
(1, 'Hieu', '0901 234 567', 18, 1, 1, 4, 1),
(2, 'Hoang', '0912 345 678', 24, 3, 3, 2, 1),
(3, 'Khai', '0987 654 321', 50, 5, 2, 2, 2),
(4, 'Chien', '0933 888 999', 34, 7, 7, 2, 3),
(5, 'Tan', '0909 876 543', 12, 2, 7, 3, 7),
(6, 'Linh', '0911 222 333', 64, 6, 5, 6, 3),
(7, 'Trung', '0999 444 555', 82, 4, 1, 6, 1);\

INSERT INTO Hospitalization (HospitalizationID, RoomID, CustomerID, NurseID, Start_Date, End_Date, Status, Modified_date, Reason_modified, Appointment, Total_Appointment)
VALUES 
(1, 1, 1, 4, '2024-01-01', '2024-01-05', 'Done', '2024-01-02', 'Busy', 1, 3),
(2, 1, 2, 2, '2024-02-10', '2024-02-20', 'Done', '2024-02/11', NULL, 1, 2),
(3, 2, 3, 2, '2024-02-01', '2024-02-07', 'Cancel', '2024-02-01', NULL, 1, 1),
(4, 3, 4, 7, '2024-03-01', '2024-03-08', 'Done', '2024-03-01', NULL, 2, 4),
(5, 7, 5, 7, '2024-03-01', '2024-03-11', 'Done', '2024-03-01', NULL, 2, 4),
(6, 3, 6, 5, '2024-04-01', '2024-04-12', 'Done', '2024-04-01', NULL, 1, 2),
(7, 1, 7, 1, '2024-05-05', '2024-05-15', 'Done', '2024-05-05', NULL, 1, 2),
(8, 1, 1, 4, '2024-05-02', '2024-05-07', 'Done', '2024-05-02', NULL, 2, 3),
(9, 1, 2, 2, '2024-06-02', '2024-06-10', 'Pending', '2024-06-01', 'Busy', 2, 2),
(10, 3, 4, 7, '2024-09-02', '2024-09-09', 'Pending', '2024-09-02', NULL, 3, 4),
(11, 7, 5, 7, '2024-09-02', '2024-09-11', 'Pending', '2024-08-30', 'Busy', 3, 4),
(12, 1, 7, 1, '2024-11-02', '2024-11-12', 'Pending', '2024-11-02', NULL, 2, 2);

select *
from Insurance

select *
from Room as R
LEFT JOIN Department as D
ON R.DepartmentID = D.DeparmentID


ALTER TABLE Customer
ALTER COLUMN Phone varchar(50);

Select * 
from Hospitalization

EXEC sp_rename 'dbo.Insurance.CustomerID', 'PatientID', 'COLUMN';

select *
from Patient



select Name_patient, Age, Name_Pathology, Name_nurse
, case when Name_patient is NOT NULL then count(Name_nurse) over (partition by Name_nurse) END as Count_nurse
from Hospitalization as Hos
Full join Patient as pat
ON Hos.PatientID = pat.PatientID
Left join Pathology as Path
On pat.PathologyID = Path.PathologyID
Full join Nurse as N
ON pat.NurseID = N.NurseID
Order by Name_nurse ASC



With table_join as (
select Hos.PatientID, Name_patient, Age, Name_Pathology, Start_Date, End_Date, Appointment, Total_Appointment 
from Hospitalization as Hos
Left join Patient as pat
ON Hos.PatientID = Pat.PatientID
Left join Pathology as Path
On pat.PathologyID = Path.PathologyID
where Appointment = 1)

, table_avg as (
select Name_Pathology
, DATEDIFF(day, Start_Date, End_date) as Time_Hopsitalization_Cus
, AVG(Cast(DATEDIFF(day, Start_Date, End_date) as FLOAT)) over (partition by Name_Pathology) as Avg_Time_Hopsitalization_Cus
--, dense_rank() over (order by DATEDIFF(day, Start_Date, End_date) DESC) as Rank_date
from table_join )

select distinct Name_Pathology, Avg_Time_Hopsitalization_Cus
, DENSE_RANK() over (order by Avg_Time_Hopsitalization_Cus DESC) as Rank_time_cus
from table_avg
order by rank_time_cus

with table_segment as (
Select P.PatientID, Name_patient, Age, Name_Pathology,
Case when Age <= 20 then '0 - 20 years old'
		when Age <= 40 then '21 - 40 years old'
		when Age <= 60 then '41 - 60 years old'
		ELSE '61 - 80 years old'
		END as Segment_age_cus

From Patient as P
Left join Pathology as Path 
On P.PathologyID = Path.PathologyID )


select distinct Segment_age_cus
, count(Name_patient) over (partition by Segment_age_cus) as Num_patient
, count(Name_patient) over () as Total_patient
, FORMAT (cast (count(Name_patient) over (partition by Segment_age_cus) as decimal) / count(Name_patient) over (), 'p') as pct_patient
from table_segment


with table_join as (
select Name_Pathology, Name_nurse
from Hospitalization as Hos
Full join Patient as pat
ON Hos.PatientID = pat.PatientID
Left join Pathology as Path
On pat.PathologyID = Path.PathologyID
Full join Nurse as N
ON pat.NurseID = N.NurseID
) 

, table_count as (
select Name_Pathology, Name_nurse
, count(Name_nurse) as Num_nurse
from table_join
Group by Name_Pathology, Name_nurse )

, table_Appendicitis as (
select Name_nurse, Num_nurse as Appendicitis
from table_count
where Name_Pathology = 'Appendicitis' )

, table_Gastrointestinal_bleeding as (
select Name_nurse, Num_nurse as Gastrointestinal_bleeding
from table_count
where Name_Pathology = 'Gastrointestinal bleeding' )

,  table_Heart_attack as (
select Name_nurse, Num_nurse as Heart_attack
from table_count
where Name_Pathology = 'Heart attack' )

,  table_Stroke as (
select Name_nurse, Num_nurse as Stroke
from table_count
where Name_Pathology = 'Stroke' )

select distinct tc.Name_nurse
, ISNULL(ta.Appendicitis,0) as Appendicitis
, ISNULL(tgb.Gastrointestinal_bleeding,0) as Gastrointestinal_bleeding
, ISNULL(tha.Heart_attack, 0) as Heart_attack
, ISNULL(ts.Stroke, 0) as Stroke
, total_pathology = ISNULL(ta.Appendicitis,0) +  ISNULL(tgb.Gastrointestinal_bleeding,0) + ISNULL(tha.Heart_attack, 0) + ISNULL(ts.Stroke, 0)
from table_count as tc
Left join table_Appendicitis as ta
ON tc.Name_nurse = ta.Name_nurse
LEFT join table_Gastrointestinal_bleeding as tgb
ON tc.Name_nurse = tgb.Name_nurse
LEFT JOIN table_Heart_attack as tha
ON tc.Name_nurse = tha.Name_nurse
LEFT JOIN table_Stroke as ts
ON tc.Name_nurse = ts.Name_nurse

with table_segment as (
Select distinct
Case when Age <= 20 then '0 - 20 years old'
		when Age <= 40 then '21 - 40 years old'
		when Age <= 60 then '41 - 60 years old'
		ELSE '61 - 80 years old'
		END as Segment_age_cus
, Name_Pathology
From Patient as P
Left join Pathology as Path 
On P.PathologyID = Path.PathologyID )

select Segment_age_cus
, STRING_AGG (Name_Pathology, ', ') WITHIN GROUP (Order by Name_Pathology ASC) as Name_Pathology
from table_segment
group by Segment_age_cus


with table_count as (
select P.PatientID, Name_patient, Age 
, ISNULL(Name_insurance, 'None') as Name_insurance
, Count(Name_insurance) over (partition by Name_patient) as Num_insurance_patient
from Patient as P
FULL join Insurance as I
On P.PatientID = I.PatientID )

select Name_patient, Num_insurance_patient
, STRING_AGG (Name_insurance, ', ') WITHIN GROUP (Order by Name_insurance ASC) as Name_insurance_patient
from table_count
group by Name_patient, Num_insurance_patient
Order by Num_insurance_patient DESC

select * 
from Hospitalization

with table_join as (
Select ISNULL(Insurance_level, 'None') as Insurance_level
, ISNULL(Case when Insurance_level IS NOT NULL Then COUNT(Name_patient) over (partition by Insurance_level) END, 0) as Num_patient
, Case when Age <= 20 then '0 - 20 years old'
		when Age <= 40 then '21 - 40 years old'
		when Age <= 60 then '41 - 60 years old'
		ELSE '61 - 80 years old'
		END as Segment_age_cus
from Patient as P
Full Join Insurance as I
On P.PatientID = I.PatientID )

, table_distinct as (
select Insurance_level, Num_patient, Segment_age_cus
from table_join )

, table_20age as (
select Insurance_level, Num_patient as [0-20 age]
from table_distinct
where Segment_age_cus = '0 - 20 years old' )

, table_40age as (
select Insurance_level, Num_patient as [21-40 age]
from table_distinct
where Segment_age_cus = '21 - 40 years old' ) 

, table_60age as (
select Insurance_level, Num_patient as [41-60 age]
from table_distinct
where Segment_age_cus = '41 - 60 years old' ) 

, table_80age as (
select Insurance_level, Num_patient as [61-80 age]
from table_distinct
where Segment_age_cus = '61 - 80 years old' ) 

select distinct td.Insurance_level 
, ISNULL([0-20 age], 0) as [0-20 age]
, ISNULL([21-40 age],0) as [21-40 age]
, ISNULL([41-60 age],0) as [41-60 age]
, ISNULL([61-80 age],0) as [61-80 age]
, Total_patient = ISNULL([0-20 age], 0) + ISNULL([21-40 age],0) + ISNULL([41-60 age],0) + ISNULL([61-80 age],0)
from table_distinct as td
Left join table_20age as age2
On td.Insurance_level = age2.Insurance_level
Left join table_40age as age4
On td.Insurance_level = age4.Insurance_level
Left join table_60age as age6
On td.Insurance_level = age6.Insurance_level
Left join table_80age as age8
On td.Insurance_level = age8.Insurance_level
where  td.Insurance_level NOT LIKE 'None'

with table_join as (
Select Name_patient, Name_Pathology
, Cast (Start_Date as date) as Start_Date
, Cast (End_Date as date) as End_Date 
, ROW_NUMBER() over (partition by Name_patient Order by Start_Date ASC) as RN_apoint
from Hospitalization as H
Left join Patient as P
On H.PatientID = P.PatientID
Left join Pathology as Pa
ON P.PathologyID = Pa.PathologyID )

, table_release as (
select Name_patient, Name_Pathology, End_Date as Hospital_release_start_first
from table_join
where RN_apoint = 1 )

, table_admission as (
select Name_patient, Name_Pathology, Start_Date as Admission_start_second
from table_join
where RN_apoint = 2) 

select tr.Name_patient, tr.Name_Pathology, Hospital_release_start_first, Admission_start_second
, DATEDIFF(day, Hospital_release_start_first, Admission_start_second) as interval_day_patient
, cast (Cast (DATEDIFF(day, Hospital_release_start_first, Admission_start_second) as decimal) / 30 as decimal (10,2)) as interval_month_patient
from table_release as tr
Left join table_admission as ta
On tr.Name_patient = ta.Name_patient
where Admission_start_second is NOT NULL
Order by interval_day_patient DESC


With table_join as (
Select Name_Deparment, Name_Pathology
from Pathology as P
Left join Doctor as D
On P.PathologyID = D.PathologyID
Left join Department as De
On D.DepartmentID = De.DepartmentID
where Name_Deparment is NOT NULL )

select Name_Deparment
, Count (Name_Pathology) as Num_Pathology
, STRING_AGG (Name_Pathology, ', ') WITHIN GROUP (Order by Name_Pathology ASC) as Name_Pathology
from table_join
Group by Name_Deparment

with table_case as (
Select *
, case when Appointment = Total_Appointment then 'Patient_Finish' 
when Appointment != Total_Appointment then 'Patient_Non_finish' 
END as Segment_Apoint
from Hospitalization )

select distinct Segment_Apoint
, count(PatientID) over (partition by Segment_Apoint) as Num_patient
, count(PatientID) over () as Total_patient
, FORMAT (cast (count(PatientID) over (partition by Segment_Apoint) as decimal) / count(PatientID) over (), 'p') as pct_patient
from table_case


with table_join as ( 
select Name_Patient, Name_Nurse, Start_Date, End_Date, Appointment, Total_Appointment
from Hospitalization as Hos
Full join Patient as pat
ON Hos.PatientID = pat.PatientID
Left join Pathology as Path
On pat.PathologyID = Path.PathologyID
Full join Nurse as N
ON pat.NurseID = N.NurseID
where Name_patient is NOT NULL )

, table_1 as (
select Name_Patient, Name_Nurse, Appointment
, COUNT(Name_Patient) OVER (Partition by Name_Nurse) as Num_cus_1
from table_join
where Appointment = 1 )

, table_2 as (
select Name_Patient, Name_Nurse, Appointment
, COUNT(Name_Patient) OVER (Partition by Name_Nurse) as Num_cus_2
from table_join
where Appointment = 2 )

, table_3 as (
select Name_Patient, Name_Nurse, Appointment
, COUNT(Name_Patient) OVER (Partition by Name_Nurse) as Num_cus_3
from table_join
where Appointment = 3 )

Select distinct tj.Name_Nurse
, ISNULL(Num_cus_1, 0) as Num_patient_Appoint_1
, ISNULL(Num_cus_2, 0) as Num_patient_Appoint_2
, ISNULL(Num_cus_3, 0) as Num_patient_Appoint_3
, Total_patient_appoint =  ISNULL(Num_cus_1, 0) +  ISNULL(Num_cus_2, 0) +  ISNULL(Num_cus_3, 0) 
from table_join as tj
Left join table_1 as t1
On tj.Name_Patient = t1.Name_Patient
Left join table_2 as t2
On tj.Name_Patient = t2.Name_Patient
Left join table_3 as t3
On tj.Name_Patient = t3.Name_Patient


with table_segment as (
Select P.PatientID, Name_patient, Age, Name_Pathology,
Case when Age <= 20 then '0 - 20 years old'
		when Age <= 40 then '21 - 40 years old'
		when Age <= 60 then '41 - 60 years old'
		ELSE '61 - 80 years old'
		END as Segment_age_cus

From Patient as P
Left join Pathology as Path 
On P.PathologyID = Path.PathologyID )

, table_format as (
Select distinct Segment_age_cus
, count(Name_patient) over (partition by Segment_age_cus) as Num_patient
, count(Name_patient) over () as Total_patient
, format(cast (count(Name_patient) over (partition by Segment_age_cus) as decimal) / count(Name_patient) over (), 'p') as pct_patient
from table_segment )

select Segment_age_cus
,CONCAT_WS('/', Num_patient, Total_patient) as Num_and_total_patient
, pct_patient
from table_format


with table_case as (
Select *
, case when Appointment = Total_Appointment then 'Patient_Finish' 
when Appointment != Total_Appointment then 'Patient_Non_finish' 
END as Segment_Apoint
from Hospitalization )

, table_format as (
select distinct Segment_Apoint
, count(PatientID) over (partition by Segment_Apoint) as Num_patient
, count(PatientID) over () as Total_patient
, FORMAT (cast (count(PatientID) over (partition by Segment_Apoint) as decimal) / count(PatientID) over (), 'p') as pct_patient
from table_case )

select Segment_Apoint
, CONCAT_WS('/', Num_patient, Total_patient) as Num_and_total_patient
, pct_patient
from table_format
