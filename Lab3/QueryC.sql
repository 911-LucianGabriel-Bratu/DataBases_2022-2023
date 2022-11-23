CREATE PROC uspSetDefaultForPriceIFS
AS
	ALTER TABLE Instruments_For_Sale
	ADD CONSTRAINT df_price 
	DEFAULT '0' FOR price
GO;

CREATE PROC uspRemoveDefaultForPriceIFS
AS
	ALTER TABLE Instruments_For_Sale
	DROP CONSTRAINT df_price;
GO;