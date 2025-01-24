CREATE TABLE Cities (
    [City ID] INT,         -- City ID with data type INT (similar to int64)
    City NVARCHAR(255),     -- City with data type NVARCHAR for text (similar to object in Python)
    State NVARCHAR(255)     -- State with data type NVARCHAR for text (similar to object in Python)
);

CREATE TABLE Departments (
    [Department ID] INT,         
    Department NVARCHAR(255)  
);

CREATE TABLE Diagnoses (
    [Diagnosis ID] INT PRIMARY KEY,         
    Diagnosis NVARCHAR(255)                
);

CREATE TABLE Insurance (
    [Insurance ID] INT PRIMARY KEY,         
    [Insurance Provider] NVARCHAR(255)                
);

CREATE TABLE Patients (
    [Patient ID] INT PRIMARY KEY,     
    [Patient Name] NVARCHAR(255),       
    Gender NVARCHAR(50),                
    Age INT,                        
    [City ID] INT,                       
    Race NVARCHAR(100)                    
);


CREATE TABLE Visit (
    [Date of Visit] DATETIME2,
    [Patient ID] INT,
    [Provider ID] INT,
    [Department ID] INT,
    [Diagnosis ID] INT,
    [Procedure ID] INT,
    [Insurance ID] INT,
    [Service Type] NVARCHAR(100),
    [Treatment Cost] INT,
    [Medication Cost] INT,
    [Follow-Up Visit Date] DATETIME2,
    [Patient Satisfaction Score] INT,
    [Referral Source] NVARCHAR(100),
    [Emergency Visit] NVARCHAR(10),
    [Payment Status] NVARCHAR(50),
    [Discharge Date] DATETIME2,
    [Admitted Date] DATETIME2,
    [Room Type] NVARCHAR(50),
    [Insurance Coverage] DECIMAL(20, 2),
    [Room Charges(daily rate)] INT
);

CREATE TABLE Patients (
    [Patient ID] INT PRIMARY KEY,               
    [Patient Name] NVARCHAR(255),                
    Gender NVARCHAR(50),                         
    [Age] INT,                   
    [City ID] INT,                             
    Race NVARCHAR(100)                          
);

CREATE TABLE [Procedures] (
    [Procedure ID] INT PRIMARY KEY,               
    [Procedure] NVARCHAR(255)                                                               
);

CREATE TABLE Providers (
    [Provider ID] INT PRIMARY KEY,              
    [Provider Name] NVARCHAR(255),             
    [Gender] NVARCHAR(25),               
    [Nationality] NVARCHAR(50),                      
    [Age] INT,                   
    [Image] NVARCHAR(100),                                                 
);

-- Liên kết khóa ngoại [Patient ID] với bảng Patients
ALTER TABLE Visit
ADD CONSTRAINT FK_PatientID FOREIGN KEY ([Patient ID]) REFERENCES Patients([Patient ID]);

-- Liên kết khóa ngoại [Provider ID] với bảng Providers (giả sử bảng Providers đã tồn tại)
ALTER TABLE Visit
ADD CONSTRAINT FK_ProviderID FOREIGN KEY ([Provider ID]) REFERENCES Providers([Provider ID]);

-- Liên kết khóa ngoại [Department ID] với bảng Departments
ALTER TABLE Visit
ADD CONSTRAINT FK_DepartmentID FOREIGN KEY ([Department ID]) REFERENCES Departments([Department ID]);

-- Liên kết khóa ngoại [Diagnosis ID] với bảng Diagnoses
ALTER TABLE Visit
ADD CONSTRAINT FK_DiagnosisID FOREIGN KEY ([Diagnosis ID]) REFERENCES Diagnoses([Diagnosis ID]);

-- Liên kết khóa ngoại [Procedure ID] với bảng Procedures (giả sử bảng Procedures đã tồn tại)
ALTER TABLE Visit
ADD CONSTRAINT FK_ProcedureID FOREIGN KEY ([Procedure ID]) REFERENCES Procedures([Procedure ID]);

-- Liên kết khóa ngoại [Insurance ID] với bảng Insurance
ALTER TABLE Visit
ADD CONSTRAINT FK_InsuranceID FOREIGN KEY ([Insurance ID]) REFERENCES Insurance([Insurance ID]);

-- Liên kết khóa ngoại [City ID] với bảng Cities
ALTER TABLE Patients
ADD CONSTRAINT FK_CityID FOREIGN KEY ([City ID]) REFERENCES Cities([City ID]);

select *
from dbo.Patients as P
Left join Cities as C
ON P.[City ID] = C.[City ID]

select *
from dbo.Insurance

select 
V.[Patient ID],
V.[Provider ID],
V.[Department ID],
V.[Diagnosis ID],
V.[Procedure ID],
V.[Insurance ID],
[Date of Visit],
[Follow-Up Visit Date],
[Service Type],
[Treatment Cost],
[Medication Cost],
[Patient Satisfaction Score],
[Referral Source],
[Emergency Visit],
[Payment Status],
[Discharge Date],
[Admitted Date],
[Room Type],
[Insurance Coverage],
[Room Charges(daily rate)],
[Patient Name],
Pa.[Gender] as Gender_Patient,
Pa.[Age] as Age_patient,
Pa.[Race] as Race_patient,
Department, Diagnosis, [Procedure], [Provider Name], [Image] as Link_image_provider
from dbo.Visit as V
Left join Patients as Pa
ON V.[Patient ID] = Pa.[Patient ID]
Left join Diagnoses as Diag
ON V.[Diagnosis ID] = Diag.[Diagnosis ID]
Left join Departments as Depart 
ON V.[Department ID] = Depart.[Department ID]
Left join Procedures as Pro
ON V.[Procedure ID] = Pro.[Procedure ID]
Left join Providers as PV
ON V.[Provider ID] = PV.[Provider ID]


Create table dbo.Visit_Patients_Analyze

select *
from dbo.Visits_Patients_Analysis


