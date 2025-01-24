USE HospitalDB;
GO
-------------------------------------------------- HANDLE DATA AND GENERATE PRIMARY KEYS --------------------------------------------------

-- Departments
ALTER TABLE Departments ALTER COLUMN [Department ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE Departments ADD CONSTRAINT PK_Departments PRIMARY KEY ([Department ID]);

-- Hospitals
ALTER TABLE Hospitals ALTER COLUMN [Hospital ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE Hospitals ADD CONSTRAINT PK_Hospitals PRIMARY KEY ([Hospital ID]);

-- Physicians
ALTER TABLE Physicians ALTER COLUMN [Provider ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE Physicians ADD CONSTRAINT PK_Physicians PRIMARY KEY ([Provider ID]);

-- Patients
ALTER TABLE Patients ALTER COLUMN [Master Patient ID] VARCHAR(150) NOT NULL;
GO
ALTER TABLE Patients ADD CONSTRAINT PK_Patients PRIMARY KEY ([Master Patient ID]);

-- Practices
ALTER TABLE Practices ALTER COLUMN [Practice ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE Practices ADD CONSTRAINT PK_Practices PRIMARY KEY ([Practice ID]);

-- SurgicalCosts
ALTER TABLE SurgicalCosts ALTER COLUMN [Surgical Cost ID] BIGINT NOT NULL;
GO
ALTER TABLE SurgicalCosts ADD CONSTRAINT PK_SurgicalCosts PRIMARY KEY ([Surgical Cost ID]);

-- SurgicalEncounters
ALTER TABLE SurgicalEncounters ALTER COLUMN [Surgery ID] BIGINT NOT NULL;
GO
ALTER TABLE SurgicalEncounters ADD CONSTRAINT PK_SurgicalEncounters PRIMARY KEY ([Surgery ID]);

-- Vitals
ALTER TABLE Vitals ALTER COLUMN [Patient Encounter ID] BIGINT NOT NULL;
GO
ALTER TABLE Vitals ADD CONSTRAINT PK_Vitals PRIMARY KEY ([Patient Encounter ID]);

-- QualityMeasureData
ALTER TABLE QualityMeasureData ALTER COLUMN [Quality Measure ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE QualityMeasureData ADD CONSTRAINT PK_QualityMeasureData PRIMARY KEY ([Quality Measure ID]);





------------------------------------------------------------------------------------------------------
-- Encounters
CREATE TABLE EncounterDetails (
    [Patient Encounter ID] VARCHAR(255),
    [Patient Admission Datetime] VARCHAR(255),
    [Patient LOS] VARCHAR(255),
    [Patient LOS Bucket] VARCHAR(255),
    [Patient LOS Bucket Sort] VARCHAR(255),
    [Patient Discharge Datetime] VARCHAR(255),
    [Patient InICU Flag] VARCHAR(255),
    [Patient Admitted Flag] VARCHAR(255),
    [Patient Readmission Flag] VARCHAR(255),
    [Patient Inpatient Readmission Flag] VARCHAR(255),
    [Discharging Provider ID] VARCHAR(255),
    [Attending Provider ID] VARCHAR(255)
);
GO

INSERT INTO EncounterDetails (
    [Patient Encounter ID], 
    [Patient Admission Datetime], 
    [Patient LOS], 
    [Patient LOS Bucket], 
    [Patient LOS Bucket Sort], 
    [Patient Discharge Datetime], 
    [Patient InICU Flag], 
    [Patient Admitted Flag], 
    [Patient Readmission Flag], 
    [Patient Inpatient Readmission Flag],
    [Discharging Provider ID],
    [Attending Provider ID]
)
SELECT DISTINCT 
    [Patient Encounter ID], 
    [Patient Admission Datetime], 
    [Patient LOS], 
    [Patient LOS Bucket], 
    [Patient LOS Bucket Sort], 
    [Patient Discharge Datetime], 
    [Patient InICU Flag], 
    [Patient Admitted Flag], 
    [Patient Readmission Flag], 
    [Patient Inpatient Readmission Flag],
    [Discharging Provider ID],
    [Attending Provider ID]
FROM Encounters;
GO

ALTER TABLE Encounters
DROP COLUMN 
    [Patient Admission Datetime], 
    [Patient LOS], 
    [Patient LOS Bucket], 
    [Patient LOS Bucket Sort], 
    [Patient Discharge Datetime], 
    [Patient InICU Flag], 
    [Patient Admitted Flag], 
    [Patient Readmission Flag], 
    [Patient Inpatient Readmission Flag],
    [Discharging Provider ID],
    [Attending Provider ID];
GO

-- -- handling redudant data in Encounters
-- WITH DuplicateEncounters AS (
--     SELECT [Patient Encounter ID]
--     FROM Encounters
--     GROUP BY [Patient Encounter ID]
--     HAVING COUNT(*) > 1
-- )
-- SELECT e.[Patient Encounter ID], e.[Master Patient ID], e.[Admitting Provider ID], e.[Department ID], e.[Hospital Account ID]
-- FROM Encounters e
-- JOIN DuplicateEncounters d ON e.[Patient Encounter ID] = d.[Patient Encounter ID];


-- drop duplicates in Encounters
WITH DuplicatesToDelete AS (
    SELECT 
        [Patient Encounter ID], 
        [Master Patient ID], 
        [Admitting Provider ID], 
        [Department ID], 
        [Hospital Account ID],
        ROW_NUMBER() OVER (
            PARTITION BY [Patient Encounter ID], [Master Patient ID], [Admitting Provider ID], [Department ID], [Hospital Account ID]
            ORDER BY [Patient Encounter ID]
        ) AS RowNum
    FROM Encounters
)
DELETE FROM DuplicatesToDelete
WHERE RowNum > 1;
GO

-- -- set primary key Patient Encounter ID
ALTER TABLE Encounters
ALTER COLUMN [Patient Encounter ID] VARCHAR(255) NOT NULL;
GO


ALTER TABLE Encounters
ADD CONSTRAINT PK_Encounters PRIMARY KEY ([Patient Encounter ID]);
GO

-- -- create contraints
ALTER TABLE EncounterDetails
ADD CONSTRAINT FK_EncounterDetails_PatientEncounter
FOREIGN KEY ([Patient Encounter ID])
REFERENCES Encounters([Patient Encounter ID]);
GO







------------------------------------------------------------------------------------------------------
-- OrderProcedures
-- -- remove ''
UPDATE OrdersProcedures
SET 
    "Order Procedure Description" = REPLACE("Order Procedure Description", '"', ''),
    "Order Procedure ID" = REPLACE("Order Procedure ID", '"', '');
GO

-- -- add new column to store non-numeric data from ID
ALTER TABLE OrdersProcedures
ADD "Order Procedure Detail" VARCHAR(255);
GO

-- --  Extracts non-numeric data to Order Procedure Detail
UPDATE OrdersProcedures
SET [Order Procedure Detail] = CASE 
    WHEN TRY_CAST([Order Procedure ID] AS INT) IS NULL THEN [Order Procedure ID]
    ELSE NULL
END;
GO

-- -- remove non-numeric data from ID column
UPDATE OrdersProcedures
SET [Order Procedure ID] = CASE 
    WHEN TRY_CAST([Order Procedure ID] AS INT) IS NULL THEN NULL
    ELSE [Order Procedure ID]
END;
GO

-- -- -- generate key values for Order Procedure ID and set it as primary key
-- UPDATE OrdersProcedures
-- SET [Order Procedure ID] = '0' + RIGHT(CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR(5)), 5)
-- WHERE [Order Procedure ID] IS NULL;
-- GO


-- -- -- create table to store duplicates
-- SELECT TOP 0 *
-- INTO Backup_OrdersProcedures
-- FROM OrdersProcedures;
-- GO

-- -- -- insert duplicates (excluding first records) into new table Backup_OrdersProcedures

-- WITH DuplicateRows AS (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY [Order Procedure ID] ORDER BY (SELECT NULL)) AS RowNum
--     FROM OrdersProcedures
-- )
-- INSERT INTO Backup_OrdersProcedures (
--     [Patient Encounter ID],
--     [Ordering Provider ID],
--     [Order CPT],
--     [Order Procedure Description],
--     [Order Procedure ID],
--     [Order Lab Status Description],
--     [Order Lab Status ID],
--     [Order Status Description],
--     [Order Parent Order ID],
--     [Order Procedure Detail]
-- )
-- SELECT 
--     [Patient Encounter ID],
--     [Ordering Provider ID],
--     [Order CPT],
--     [Order Procedure Description],
--     [Order Procedure ID],
--     [Order Lab Status Description],
--     [Order Lab Status ID],
--     [Order Status Description],
--     [Order Parent Order ID],
--     [Order Procedure Detail]
-- FROM DuplicateRows
-- WHERE RowNum > 1;
-- GO

-- -- -- delete duplicates out of table
-- WITH DuplicateRows AS (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY [Order Procedure ID] ORDER BY (SELECT NULL)) AS RowNum
--     FROM OrdersProcedures
-- )
-- DELETE FROM DuplicateRows
-- WHERE RowNum > 1;
-- GO

-- -- create primary key
-- GO
-- ALTER TABLE OrdersProcedures ALTER COLUMN [Order Procedure ID] VARCHAR(50) NOT NULL;
-- GO
-- ALTER TABLE OrdersProcedures ADD CONSTRAINT PK_OrdersProcedures PRIMARY KEY ([Order Procedure ID]);
-- GO




------------------------------------------------------------------------------------------------------
-- Accounts
-- -- remove duplicates keeping non-nulls in HHRP Condition
WITH DuplicateRowsToDelete AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Hospital Account ID] ORDER BY CASE WHEN [HRRP Condition] IS NULL OR LTRIM(RTRIM([HRRP Condition])) = '' THEN 1 ELSE 0 END) AS RowNum
    FROM Accounts
)
DELETE FROM DuplicateRowsToDelete
WHERE RowNum > 1 AND ( [HRRP Condition] IS NULL OR LTRIM(RTRIM([HRRP Condition])) = '' );

-- -- create primary key
GO
ALTER TABLE Accounts ALTER COLUMN [Hospital Account ID] VARCHAR(50) NOT NULL;
GO
ALTER TABLE Accounts ADD CONSTRAINT PK_Accounts PRIMARY KEY ([Hospital Account ID]);
GO





------------------------------------------------------------------------------------------------------
-- Results
---- Remove duplicates 
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY 
               AbnormalFlagType,
               AcknowledgementReqFLAG,
               ActivityHeaderResultID,
               AnswerDataTypeCode,
               AnswerDataTypeDE,
               AnswerDataTypeName,
               AnswerDE,
               AnswerDET,
               AnswerEntryCode,
               AnswerEntryName,
               [Clinical Datetime],
               CompletionStatus,
               [Create Datetime],
               DecodedValue,
               DetailType,
               EntryCode,
               Entryname,
               HasAnnotationFLAG,
               HasReferenceRangeFLAG,
               HasRefRangeTextFLAG,
               HasResultTextFLAG,
               HasSecurityFLAG,
               IsAbnormalFLAG,
               IsErrorFLAG,
               ItemID,
               [Last Update Datetime],
               LoincLabCode,
               [Master Patient ID],
               Modifier1Name,
               Modifier2Name,
               Modifier3Name,
               NormalizedUnitsCode,
               NormalizedUnitsDET,
               NormalizedUnitsName,
               NormalizedValue,
               NumericResult,
               OrderableCode,
               OrderableName,
               [Performed Datetime],
               QOClassificationDE,
               QOClassificationDET,
               QODE,
               QODET,
               QOModDET,
               ReasonForCreateType,
               [Recorded Datetime],
               [Result Datetime],
               ResultAnswer,
               ResultFuzzyWhen,
               ResultID,
               ResultStage,
               ResultStatusCode,
               ResultStatusName,
               ShortRefRange,
               SignatureRequiredFLAG,
               SourceCode,
               SourceDET,
               SourceName,
               UnitsCode,
               UnitsDET,
               UnitsName,
               ValidationState,
               [Verify Datetime]
           ORDER BY (SELECT NULL)) AS RowNum
    FROM Results
)
DELETE FROM CTE
WHERE RowNum > 1;
GO

---- Create a new column as key
ALTER TABLE Results
ADD ResultEntryID INT IDENTITY(1,1) PRIMARY KEY;


-------------------------------------------------- GENERATE CONTRAINTS --------------------------------------------------
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

------------------------------------------------------------------------------------------------------
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



------------------------------------------------------------------------------------------------------
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



select *
from dbo.OrdersProcedures

































