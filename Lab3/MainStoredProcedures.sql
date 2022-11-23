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
	ADD PRIMARY KEY (cID);
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

CREATE OR ALTER PROC uspAddIFSClientNameFK
AS
	ALTER TABLE Instruments_For_Sale
	ADD CONSTRAINT FK_ClientName
	FOREIGN KEY (ClientName) REFERENCES Client(name)
GO

CREATE OR ALTER PROC uspRemoveIFSClientNameFK
AS
	ALTER TABLE Instruments_For_Sale
	DROP CONSTRAINT FK_ClientName
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