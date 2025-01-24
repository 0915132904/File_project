USE HospitalDB;
GO

------------------------------------------------------------------------------------------------------
-- Reference Encounters
--Reference Encounters and Physicians
ALTER TABLE Encounters
ADD CONSTRAINT FK_Encounters_Physicians
FOREIGN KEY ([Admitting Provider ID])
REFERENCES Physicians([Provider ID]);
GO

--Reference Encounters and OrdersProcedures
ALTER TABLE OrdersProcedures
ALTER COLUMN [Patient Encounter ID] VARCHAR(255);
GO

ALTER TABLE OrdersProcedures
ADD CONSTRAINT FK_Encounters_OrdersProcedures
FOREIGN KEY ([Patient Encounter ID]) 
REFERENCES Encounters([Patient Encounter ID]);
GO

--Reference Encounters and Vitals
ALTER TABLE Vitals
DROP CONSTRAINT PK_Vitals;
GO

ALTER TABLE Vitals
ALTER COLUMN [Patient Encounter ID] VARCHAR(255);
GO

ALTER TABLE Vitals
ADD CONSTRAINT FK_Encounters_Vitals
FOREIGN KEY ([Patient Encounter ID]) REFERENCES Encounters([Patient Encounter ID]);
GO


--Reference Encounters and Accounts
UPDATE Encounters
SET [Hospital Account ID] = NULL
WHERE [Hospital Account ID] = '';
GO

ALTER TABLE Encounters
ADD CONSTRAINT FK_Encounters_Accounts
FOREIGN KEY ([Hospital Account ID]) REFERENCES Accounts([Hospital Account ID]);
GO

--Reference Encounters and Deparments
ALTER TABLE Encounters
ADD CONSTRAINT FK_Encounters_Department
FOREIGN KEY ([Department ID])
REFERENCES Departments ([Department ID]);
GO

--Reference Encounters and Patients
ALTER TABLE Encounters
ALTER COLUMN [Master Patient ID] VARCHAR(150);
GO

ALTER TABLE Encounters
ADD CONSTRAINT FK_Encounters_Patients
FOREIGN KEY ([Master Patient ID]) 
REFERENCES Patients([Master Patient ID]);
GO

------------------------------------------------------------------------------------------------------
---Reference Patients
-- Reference Patient and QualityMeasureData 
-- Tạo bảng phụ 
CREATE TABLE QualityMeasureInternal(
	[Master Patient ID] VARCHAR(150) PRIMARY KEY,
	[Quality Measure ID] varchar(50));

-- insert data
INSERT INTO QualityMeasureInternal ([Master Patient ID])
SELECT DISTINCT 
	[Master Patient ID]
FROM Patients
WHERE [Master Patient ID] IS NOT NULL;  
GO

-- ?
UPDATE pg
SET pg.[Quality Measure ID] = se.[Quality Measure ID]
FROM QualityMeasureInternal pg
LEFT JOIN QualityMeasureData se ON pg.[Master Patient ID] = se.[Master Patient ID];
GO

-- tạo key giữa 3 bảng
ALTER TABLE QualityMeasureData
ALTER COLUMN [Master Patient ID] VARCHAR(150);
GO

ALTER TABLE QualityMeasureInternal
ADD CONSTRAINT FK_QualityMeasureInternal_Patients
FOREIGN KEY ([Master Patient ID]) REFERENCES Patients([Master Patient ID]);
GO

ALTER TABLE QualityMeasureInternal
ADD CONSTRAINT FK_QualityMeasureData_QualityMeasureInternal
FOREIGN KEY ([Quality Measure ID]) REFERENCES QualityMeasureData([Quality Measure ID]);
GO


--Reference Patients and SurgicalEncounters
--Tạo bảng phụ PatientInternal
CREATE TABLE PatientInternal (
	[Master Patient ID] VARCHAR(150) PRIMARY KEY,
	[Surgery ID] bigint);
GO

INSERT INTO PatientInternal ([Master Patient ID])
SELECT DISTINCT 
    [Master Patient ID] 
FROM Patients
WHERE [Master Patient ID] IS NOT NULL;  
GO

UPDATE pg
SET pg.[Surgery ID] = se.[Surgery ID]
FROM PatientInternal pg
LEFT JOIN SurgicalEncounters se ON pg.[Master Patient ID] = se.[Master Patient ID];
GO


ALTER TABLE PatientInternal
ADD CONSTRAINT FK_PatientInternal_Patients
FOREIGN KEY ([Master Patient ID]) REFERENCES Patients([Master Patient ID]);
GO


ALTER TABLE SurgicalEncounters
ALTER COLUMN [Master Patient ID] VARCHAR(150);
GO

ALTER TABLE PatientInternal
ADD CONSTRAINT FK_SurgicalEncounters_PatientInternal
FOREIGN KEY ([Surgery ID])
REFERENCES SurgicalEncounters([Surgery ID]);




--Reference SurgicalEncounters and SurgicalCosts
CREATE TABLE SurgicalInternal (
    MappingID INT PRIMARY KEY IDENTITY(1,1),
    [Surgery ID] bigint,
    [Surgical Cost ID] bigint
);
GO

INSERT INTO SurgicalInternal ([Surgery ID], [Surgical Cost ID])
SELECT e.[Surgery ID], c.[Surgical Cost ID]
FROM SurgicalEncounters e
JOIN SurgicalCosts c ON e.[Surgery ID] = c.[Surgery ID];
GO

ALTER TABLE SurgicalInternal
ADD CONSTRAINT FK_SurgeryID
FOREIGN KEY ([Surgery ID]) REFERENCES SurgicalEncounters([Surgery ID]);
GO

ALTER TABLE SurgicalInternal
ADD CONSTRAINT FK_SurgicalCostID
FOREIGN KEY ([Surgical Cost ID]) REFERENCES SurgicalCosts([Surgical Cost ID]);
GO

------------------------------------------------------------------------------------------------------
-- Reference Deparments and Hospitals
ALTER TABLE Departments
ADD CONSTRAINT FK_Departments_Hospitals
FOREIGN KEY ([Hospital ID])
REFERENCES Hospitals([Hospital ID]);
GO


------------------------------------------------------------------------------------------------------
----Reference QualityMeasureData and Practice
ALTER TABLE QualityMeasureData
ADD CONSTRAINT FK_QualityMeasureData_Practice
FOREIGN KEY ([Practice ID])
REFERENCES Practices([Practice ID]);
GO


------------------------------------------------------------------------------------------------------
----Reference Hospital and QualityMeasureData
ALTER TABLE QualityMeasureData
ADD CONSTRAINT FK_QualityMeasureData_Hospital
FOREIGN KEY ([Hospital ID])
REFERENCES Hospitals([Hospital ID]);
GO


------------------------------------------------------------------------------------------------------
--Reference Patients and Results 
ALTER TABLE Results
ALTER COLUMN [Master Patient ID] VARCHAR(150);
GO

ALTER TABLE Results
ADD CONSTRAINT FK_result_patient
FOREIGN KEY ([Master Patient ID])
REFERENCES Patients([Master Patient ID]);
GO

use HospitalDB EXEC sp_changedbowner 'sa'

select count(*) -- 1285783
from dbo.Backup_OrdersProcedures
Group by [Order Procedure ID]

select count(*)
from dbo.OrdersProcedures