USE [Musical-Instruments-Store-DB]

GO

CREATE OR ALTER PROCEDURE addToTables (@tableName VARCHAR(50)) AS
BEGIN
	IF @tableName IN (SELECT [Name] FROM [Tables])
	BEGIN
		PRINT 'Table already in Tables'
		RETURN
	END

	IF @tableName NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES)
	BEGIN
		PRINT 'Table is not in the database'
		RETURN
	END

	INSERT INTO [Tables] ([Name])
	VALUES
		(@tableName)
END

GO

CREATE OR ALTER PROCEDURE addToViews (@viewName VARCHAR(50)) AS
BEGIN
	IF @viewName IN (SELECT [Name] FROM [Views])
	BEGIN
		PRINT 'View already in Views'
		RETURN
	END
	IF @viewName IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)
	BEGIN
		PRINT 'View is not in the database'
		RETURN
	END

	INSERT INTO [Views] ([Name])
	VALUES
		(@viewName)
END

GO

CREATE OR ALTER PROCEDURE addToTests (@testName VARCHAR(50)) AS
BEGIN
	IF @testName IN (SELECT [Name] FROM [Tests])
	BEGIN
		PRINT 'Test already in Tests'
		RETURN
	END
	INSERT INTO [Tests] ([Name])
	VALUES
		(@testName)
END

GO
CREATE OR ALTER PROCEDURE connectTableToTest (@tableName VARCHAR(50), @testName VARCHAR(50), @rows INT, @pos INT) AS
BEGIN
	IF @tableName NOT IN (SELECT [Name] FROM [Tables])
		BEGIN
			PRINT 'Test not in Test'
			RETURN
		END
	IF EXISTS (
		SELECT *
		FROM TestTables T1 JOIN Tests T2 ON T1.TestID = T2.TestID
		WHERE T2.[Name] = @testName AND Position = @pos
	)
		BEGIN
			PRINT 'Given pos conflicts with previous positions'
			RETURN
		END

	INSERT INTO [TestTables] (TestID, TableID, NoOfRows, Position)
	VALUES (
			(SELECT [Tests].TestID FROM [Tests] WHERE [Name] = @testName),
			(SELECT [Tables].TableID FROM [Tables] WHERE [Name] = @tableName),
			@rows,
			@pos
	)
END

GO

CREATE OR ALTER PROCEDURE connectViewToTest(@viewName VARCHAR(50), @testName VARCHAR(50)) AS
BEGIN
		IF @viewName NOT IN (SELECT [Name] FROM [Views])
		BEGIN
			PRINT 'View not in Views'
			RETURN
		END

	IF @testName NOT IN (SELECT [Name] FROM [Tests])
		BEGIN
			PRINT 'Test not in Tests'
			RETURN
		END
	INSERT INTO [TestViews] (TestID, ViewID)
	VALUES (
			(SELECT [Tests].TestID FROM [Tests] WHERE [Name] = @testName),
			(SELECT [Views].ViewID FROM [Views] WHERE [Name] = @viewName)
		)
END

GO

CREATE OR ALTER PROCEDURE deleteDataFromTable (@tableID INT) AS
BEGIN
	IF @tableID NOT IN (SELECT [TableID] FROM [Tables])
	BEGIN
		PRINT 'Table not in Tables'
		RETURN
	END
	DECLARE @tableName NVARCHAR(50) = (SELECT [Name] FROM [Tables] WHERE TableID = @tableID)
	PRINT 'Delete data from table ' + @tableName
	DECLARE @query NVARCHAR(100) = N'Delete from ' + @tableName
	PRINT @query
	EXEC sp_executesql @query
END

GO
CREATE OR ALTER PROCEDURE deleteDataFromAllTables (@testID INT) AS
BEGIN
	IF @testID NOT IN (SELECT [TestID] from [TESTS])
	BEGIN
		PRINT 'Test not in Tests'
		RETURN
	END
	PRINT 'Delete data from all tables for the test ' + CONVERT(VARCHAR, @testID)
	DECLARE @tableID INT
	DECLARE @pos INT
	DECLARE allTableCursorDesc CURSOR LOCAL FOR
		SELECT T1.TableID, T1.Position
		FROM TestTables T1
		INNER JOIN Tests T2 ON T2.TestID = T1.TestID
		WHERE T2.TestID = @testID
		ORDER BY T1.Position DESC

	OPEN allTableCursorDesc
	FETCH allTableCursorDesc INTO @tableID, @pos
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC deleteDataFromTable @tableID
		FETCH NEXT FROM allTableCursorDesc INTO @tableID, @pos
	END
	CLOSE allTableCursorDesc
	DEALLOCATE allTableCursorDesc
END

GO 

CREATE OR ALTER PROCEDURE insertDataIntoTable (@testRunID INT, @testID INT, @tableID INT) AS
BEGIN
	IF @testID NOT IN (SELECT [TestID] FROM [Tests])
		BEGIN
			PRINT 'Test not in Tests'
			RETURN
		END
	IF @testRunID NOT IN (SELECT [TestRunID] FROM [TestRuns])
		BEGIN
			PRINT 'Test not in TestRuns'
			RETURN
		END
	IF @tableID NOT IN (SELECT [TableID] FROM [Tables])
		BEGIN
			PRINT 'Table not in Tables'
			RETURN
		END
	DECLARE @startTime DATETIME = SYSDATETIME()
	DECLARE @tableName VARCHAR(50) = (
		SELECT [Name]
		FROM [Tables]
		WHERE TableID = @tableId
	)
	PRINT 'Insert data into table ' + @tableName
	DECLARE @numberOfRows INT = (
		SELECT [NoOfRows]
		FROM [TestTables]
		WHERE TestID = @testID AND TableID = @tableId
	)
	EXEC generateDataForTable @tableName, @numberOfRows
	DECLARE @endTime DATETIME = SYSDATETIME()
	INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt)
	VALUES (@testRunID, @tableID, @startTime, @endTime)
END

GO

CREATE OR ALTER PROCEDURE insertDataIntoAllTables (@testRunID INT, @testID INT) AS
BEGIN
	IF @testID NOT IN (SELECT [TestID] FROM [Tests])
	BEGIN
		PRINT 'Test not present in Tests.'
		RETURN
	END

	IF @testRunID NOT IN (SELECT [TestRunID] FROM [TestRuns])
	BEGIN
		PRINT 'Test run not present in TestRuns.'
		RETURN
	END

	PRINT 'Insert data in all the tables for the test ' + CONVERT(VARCHAR, @testID)
	DECLARE @tableID INT
	DECLARE @pos INT
	DECLARE allTableCursorAsc CURSOR LOCAL FOR
		SELECT T1.TableID, T1.Position
		FROM TestTables T1
		INNER JOIN Tests T2 ON T2.TestID = T1.TestID
		WHERE T1.TestID = @testID
		ORDER BY T1.Position ASC

	OPEN allTableCursorAsc
	FETCH allTableCursorAsc INTO @tableID, @pos
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC insertDataIntoTable @testRunID, @testID, @tableID
		FETCH NEXT FROM allTableCursorAsc INTO @tableID, @pos
	END
	CLOSE allTableCursorAsc
	DEALLOCATE allTableCursorAsc
END

GO

CREATE OR ALTER PROCEDURE selectDataFromView (@viewID INT, @testRunID INT) AS
BEGIN
	IF @viewID NOT IN (SELECT [ViewID] FROM [Views])
	BEGIN
		PRINT 'View not present in Views.'
		RETURN
	END

	IF @testRunID NOT IN (SELECT [TestRunID] FROM [TestRuns])
	BEGIN
		PRINT 'Test run not present in TestRuns.'
		RETURN
	END

	DECLARE @startTime DATETIME = SYSDATETIME()
	DECLARE @viewName VARCHAR(100) = (
		SELECT [Name]
		FROM [Views]
		WHERE ViewID = @viewID
	)
	PRINT 'Selecting data from the view ' + @viewName
	DECLARE @query NVARCHAR(150) = N'SELECT * FROM ' + @viewName
	EXEC sp_executesql @query

	DECLARE @endTime DATETIME = SYSDATETIME()
	INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt)
	VALUES (@testRunID, @viewID, @startTime, @endTime)
END

GO

CREATE OR ALTER PROCEDURE selectAllViews (@testRunID INT, @testID INT) AS
BEGIN
	IF @testID NOT IN (SELECT [TestID] FROM [Tests])
	BEGIN
		PRINT 'Test not present in Tests.'
		RETURN
	END

	IF @testRunID NOT IN (SELECT [TestRunID] FROM [TestRuns])
	BEGIN
		PRINT 'Test run not present in TestRuns.'
		RETURN
	END

	PRINT 'Selecting data from all the views from the test ' + CONVERT(VARCHAR, @testID)
	DECLARE @viewID INT
	DECLARE selectAllViewsCursor CURSOR LOCAL FOR
		SELECT T1.ViewID FROM TestViews T1
		INNER JOIN Tests T2 ON T2.TestID = T1.TestID
		WHERE T1.TestID = @testID

	OPEN selectAllViewsCursor
	FETCH selectAllViewsCursor INTO @viewID
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXEC selectDataFromView @viewID, @testRunID
		FETCH NEXT FROM selectAllViewsCursor INTO @viewID
	END
	CLOSE selectAllViewsCursor
	DEALLOCATE selectAllViewsCursor
END



GO
CREATE OR ALTER PROCEDURE runTest (@testID INT, @description VARCHAR(MAX)) AS
BEGIN
	IF @testID NOT IN (SELECT [TestID] FROM [Tests])
	BEGIN
		PRINT 'Test not present in Tests.'
		RETURN
	END

	PRINT 'Running test with the id ' + CONVERT(VARCHAR, @testID)
	INSERT INTO TestRuns([Description]) 
	VALUES (@description)
	DECLARE @testRunID INT = (
		SELECT MAX(TestRunID)
		FROM TestRuns
	)
	DECLARE @startTime DATETIME = SYSDATETIME()
	EXEC insertDataIntoAllTables @testRunID, @testID
	EXEC selectAllViews @testRunID, @testID
	DECLARE @endTime DATETIME = SYSDATETIME()
	EXEC deleteDataFromAllTables @testID

	UPDATE [TestRuns] SET StartAt = @startTime, EndAt = @endTime
	DECLARE @timeDifference INT = DATEDIFF(SECOND, @startTime, @endTime)
	PRINT 'The test with id ' + CONVERT(VARCHAR, @testID) + ' took ' + CONVERT(VARCHAR, @timeDifference) + ' seconds.'
END

GO
CREATE OR ALTER PROCEDURE runAllTests AS
BEGIN
	DECLARE @testName VARCHAR(50)
	DECLARE @testID INT
	DECLARE @description VARCHAR(2000)
	DECLARE allTestsCursor CURSOR LOCAL FOR
		SELECT *
		FROM Tests

	OPEN allTestsCursor
	FETCH allTestsCursor INTO @testID, @testName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Running ' + @testName
		SET @description = 'Test results for test with the ID ' + CAST(@testID AS VARCHAR(2))
		EXEC runTest @testID, @description
		FETCH NEXT FROM allTestsCursor INTO @testID, @testName
	END
	CLOSE allTestsCursor
	DEALLOCATE allTestsCursor
END

GO

-- a view with a SELECT statement operating on one table
CREATE OR ALTER VIEW instrumentsMoreExpensiveThan500 AS
	SELECT IFS.insID, IFS.manufacturer, IFS.price
	FROM Instruments_For_Sale IFS
	WHERE IFS.price > 500

GO

-- a view with a SELECT statement operating on at least 2 tables
CREATE OR ALTER VIEW insExpertsAndMIShops AS
	SELECT IE.name, MIS.address
	FROM Instruments_Expert IE INNER JOIN Musical_instruments_shop MIS ON IE.miID = MIS.miID

GO

-- a view with a SELECT statement that has a GROUP BY clause and operates on at least 2 tables
CREATE OR ALTER VIEW groupInsByMIS AS
	SELECT HII.insID, HII.miID, COUNT(*) AS nr
	FROM Has_In_Inventory HII
	INNER JOIN Musical_instruments_shop MIS ON HII.miID = MIS.miID
	GROUP BY HII.insID, HII.miID

GO

--Test1
EXEC addToViews 'dbo.groupInsByMIS'
EXEC addToTests 'Test1'
EXEC addToTables 'Has_In_Inventory'
EXEC connectTableToTest 'Has_In_Inventory', 'Test1', 500, 1
EXEC addToTables 'Musical_instruments_shop'
EXEC connectTableToTest 'Musical_instruments_shop', 'Test1', 500, 2
EXEC addToTables 'Instruments_For_Sale'
EXEC connectTableToTest 'Instruments_For_Sale', 'Test1', 500, 3
EXEC addToTables 'Instruments_Expert'
EXEC connectTableToTest 'Instruments_Expert', 'Test1', 500, 4
EXEC connectViewToTest 'dbo.groupInsByMIS', 'Test1'

--Test2
EXEC addToViews 'dbo.instrumentsMoreExpensiveThan500'
EXEC addToTests 'Test2'
EXEC addToTables 'Instruments_For_Sale'
EXEC connectTableToTest 'Instruments_For_Sale', 'Test2', 500, 1
EXEC connectViewToTest 'dbo.instrumentsMoreExpensiveThan500', 'Test2'

--Test3
EXEC addToViews 'dbo.insExpertsAndMIShops'
EXEC addToTests 'Test3'
EXEC addToTables 'Instruments_Expert'
EXEC connectTableToTest 'Instruments_Expert', 'Test3', 500, 1
EXEC addToTables 'Musical_instruments_shop'
EXEC connectTableToTest 'Musical_instruments_shop', 'Test3', 500, 2
EXEC connectViewToTest 'dbo.insExpertsAndMIShops', 'Test3'

EXEC runAllTests

SELECT *
FROM [Views]

SELECT *
FROM [Tables]

SELECT *
FROM [Tests]

SELECT *
FROM [TestTables]

SELECT *
FROM [TestViews]

SELECT *
FROM [TestRuns]

SELECT *
FROM [TestRunTables]

SELECT *
FROM [TestRunViews]