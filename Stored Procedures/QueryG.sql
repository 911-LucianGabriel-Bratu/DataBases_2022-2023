CREATE PROC uspDropTableJanitor
AS
	DROP TABLE Janitor
GO;

CREATE PROC uspAddTableJanitor
AS
	CREATE TABLE Janitor (
		jID INT PRIMARY KEY,
		miID INT REFERENCES Musical_instruments_shop(miID),
		name char(20),
		CNP char(20)
	)
GO;