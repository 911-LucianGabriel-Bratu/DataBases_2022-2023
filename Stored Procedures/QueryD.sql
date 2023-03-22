CREATE PROC uspRemoveCashierIDPK
AS
	ALTER TABLE Cashier
	DROP CONSTRAINT cID;
GO;

CREATE PROC uspAddCashierIDPK
AS
	ALTER TABLE Cashier
	ADD PRIMARY KEY (cID);
GO;

EXEC uspRemoveCashierIDPK;

EXEC uspAddCashierIDPK;