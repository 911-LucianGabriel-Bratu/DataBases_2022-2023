CREATE PROC uspAddRatingToIFS
AS
	ALTER TABLE Instruments_For_Sale
	ADD rating INT;
GO;

CREATE PROC uspRemoveRatingFromIFS
AS
	ALTER TABLE Instruments_For_Sale
	DROP COLUMN rating;
GO;

EXEC uspAddRatingToIFS;

EXEC uspRemoveRatingFromIFS;