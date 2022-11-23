CREATE PROC uspAddIFSClientNameFK
AS
	ALTER TABLE Instruments_For_Sale
	ADD CONSTRAINT FK_ClientName
	FOREIGN KEY (ClientName) REFERENCES Client(name)
GO;

CREATE PROC uspRemoveIFSClientNameFK
AS
	ALTER TABLE Instruments_For_Sale
	DROP CONSTRAINT FK_ClientName
GO;