--a. modify the type of a column;

CREATE PROC uspInstrumentChangePriceToInt
AS
	ALTER TABLE Instruments_For_Sale 
	ALTER COLUMN price INT;
GO;

CREATE PROC uspInstrumentChangePriceToDecimal
AS
	ALTER TABLE Instruments_For_Sale 
	ALTER COLUMN price DECIMAL(10,2);
GO;

EXEC uspInstrumentChangePriceToInt;

EXEC uspInstrumentChangePriceToDecimal;