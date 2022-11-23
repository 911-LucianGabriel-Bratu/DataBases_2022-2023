USE [Musical-Instruments-Store-DB];
GO

--a. modify the type of a column;
CREATE OR ALTER PROC uspInstrumentChangePriceToInt
AS
	ALTER TABLE Instruments_For_Sale 
	ALTER COLUMN price INT
GO

CREATE OR ALTER PROC uspInstrumentChangePriceToDecimal
AS
	ALTER TABLE Instruments_For_Sale 
	ALTER COLUMN price DECIMAL(10,2)
GO

--b. add / remove a column;

CREATE OR ALTER PROC uspAddRatingToIFS
AS
	ALTER TABLE Instruments_For_Sale
	ADD rating INT
GO

CREATE OR ALTER PROC uspRemoveRatingFromIFS
AS
	ALTER TABLE Instruments_For_Sale
	DROP COLUMN rating
GO

--c. add / remove a DEFAULT constraint;

CREATE OR ALTER PROC uspSetDefaultForPriceIFS
AS
	ALTER TABLE Instruments_For_Sale
	ADD CONSTRAINT df_price 
	DEFAULT '0' FOR price
GO

CREATE OR ALTER PROC uspRemoveDefaultForPriceIFS
AS
	ALTER TABLE Instruments_For_Sale
	DROP CONSTRAINT df_price
GO

--d. add / remove a primary key;

CREATE OR ALTER PROC uspRemoveCashierIDPK
AS
	ALTER TABLE Cashier
	DROP CONSTRAINT cID;
GO

CREATE OR ALTER PROC uspAddCashierIDPK
AS
	ALTER TABLE Cashier
	ADD CONSTRAINT cID PRIMARY KEY (cID);
GO
--e. add / remove a candidate key;

CREATE OR ALTER PROC uspAddCNPCKClient
AS
	ALTER TABLE Client
	ADD CNP varchar(30)
	ALTER TABLE Client
	ADD CONSTRAINT CK_CNP UNIQUE(CNP)
GO

CREATE OR ALTER PROC uspRemoveCNPCKClient
AS
	ALTER TABLE Client
	DROP CONSTRAINT CK_CNP
	ALTER TABLE Client
	DROP COLUMN CNP
GO

--f. add / remove a foreign key;

CREATE OR ALTER PROC uspRemoveIFSClientIDFK
AS
	ALTER TABLE Instruments_For_Sale
	DROP CONSTRAINT FK_cID
GO

CREATE OR ALTER PROC uspAddIFSClientIDFK
AS
	ALTER TABLE Instruments_For_Sale
	ADD CONSTRAINT FK_cID FOREIGN KEY(cID)
	REFERENCES Client(cID)
GO

--g. create / drop a table.

CREATE OR ALTER PROC uspDropTableJanitor
AS
	DROP TABLE Janitor
GO

CREATE OR ALTER PROC uspAddTableJanitor
AS
	CREATE TABLE Janitor (
		jID INT PRIMARY KEY,
		miID INT REFERENCES Musical_instruments_shop(miID),
		name char(20),
		CNP char(20)
	)
GO

CREATE TABLE currentVersionTable(
	currentVersion INT PRIMARY KEY
)

INSERT INTO currentVersionTable
VALUES
	(1) -- current version

CREATE TABLE databaseVersionTable
(
	upSP VARCHAR(100),
	bSP VARCHAR(100),
	targetedVersion INT,
	PRIMARY KEY(upSP, bSP, targetedVersion)
);


INSERT INTO databaseVersionTable
VALUES
	('uspInstrumentChangePriceToInt', 'uspInstrumentChangePriceToDecimal', '1'),
	('uspAddRatingToIFS', 'uspRemoveRatingFromIFS', '2'),
	('uspSetDefaultForPriceIFS', 'uspRemoveDefaultForPriceIFS', '3'),
	('uspRemoveCashierIDPK', 'uspAddCashierIDPK', '4'),
	('uspAddCNPCKClient', 'uspRemoveCNPCKClient', '5'),
	('uspRemoveIFSClientIDFK', 'uspAddIFSClientIDFK', '6'),
	('uspDropTableJanitor', 'uspAddTableJanitor', '7')

GO
CREATE OR ALTER PROCEDURE updateDBVersion(@inputVersion INT)
AS
	DECLARE @currentVersion INT
	DECLARE @procedureName VARCHAR(100)
	SELECT @currentVersion = currentVersion FROM currentVersionTable

	IF (@inputVersion > (SELECT MAX(targetedVersion) FROM databaseVersionTable) OR @inputVersion < 1)
		RAISERROR ('Incorrect version', 10, 1)
	ELSE
	BEGIN
		IF @inputVersion = @currentVersion
			PRINT('Input version is the same as the current version');
		ELSE
		BEGIN
			IF @currentVersion > @inputVersion
			BEGIN
				WHILE @currentVersion > @inputVersion OR @inputVersion = @currentVersion
					BEGIN
						SELECT @procedureName = bSP FROM databaseVersionTable WHERE @currentVersion = targetedVersion
						PRINT('Executing usp: ' + @procedureName)
						EXEC(@procedureName)
						SET @currentVersion = @currentVersion - 1
					END
				SET @currentVersion = @currentVersion + 1
			END
			IF @currentVersion < @inputVersion
			BEGIN
				WHILE @currentVersion < @inputVersion OR @currentVersion = @inputVersion
					BEGIN
						SELECT @procedureName = upSP FROM databaseVersionTable WHERE @currentVersion = targetedVersion
						PRINT('Executing usp: ' + @procedureName)
						EXEC(@procedureName)
						SET @currentVersion = @currentVersion + 1
					END
				SET @currentVersion = @currentVersion - 1
			END

			UPDATE currentVersionTable SET currentVersion = @inputVersion
		END
	END

EXEC updateDBVersion 1

SELECT *
FROM currentVersionTable

SELECT *
FROM databaseVersionTable
ORDER BY targetedVersion