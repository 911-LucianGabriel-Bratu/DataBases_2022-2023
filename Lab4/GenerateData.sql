GO

IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('generateRandomString'))
BEGIN
   DROP PROCEDURE generateRandomString;
END

IF EXISTS (SELECT [name] FROM sys.objects
			WHERE object_id = OBJECT_ID('generateDataForTable'))
BEGIN
	DROP PROCEDURE generateRandomDataForTable
END

GO 

CREATE OR ALTER PROCEDURE generateRandomString @stringValue VARCHAR(10) OUTPUT AS
BEGIN
	DECLARE @length INT
	DECLARE @charPool VARCHAR(55)
	DECLARE @charPoolLength INT
	SET @charPool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	SET @charPoolLength = LEN(@charPool)
	SET @length = FLOOR(RAND() * 10 + 5)
	SET @stringValue = ''
	WHILE @length > 0
	BEGIN
		SET @stringValue = @stringValue + SUBSTRING(@charPool, CONVERT(INT, RAND() * @charPoolLength) + 1, 1)
		SET @length = @length - 1
	END
END

GO

CREATE OR ALTER PROCEDURE generateDataForTable @tableName VARCHAR(50), @numberOfRows INT AS
BEGIN
	DECLARE dataCursor SCROLL CURSOR FOR
		SELECT COLUMN_NAME, DATA_TYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @tableName
		ORDER by ORDINAL_POSITION

	DECLARE @insertQuery VARCHAR(MAX)
	DECLARE @columnName VARCHAR(200)
	DECLARE @dataType VARCHAR(10)
	DECLARE @intValue INT
	DECLARE @stringValue VARCHAR(50)

	OPEN dataCursor

	WHILE @numberOfRows > 0
		BEGIN
			SET @insertQuery = 'INSERT INTO ' + @tableName + ' VALUES('
			FETCH FIRST FROM dataCursor INTO @columnName, @dataType
			WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @dataType = 'int'
							BEGIN
								-- generate a random number
								SET @intValue = FLOOR(RAND() * 1000) + 1
								SET @insertQuery = @insertQuery + CAST(@intValue AS NVARCHAR(10)) + ','
							END
						ELSE
							IF @dataType = 'varchar'
								BEGIN
									-- generate a random string
									EXEC generateRandomString @stringValue OUTPUT
									SET @insertQuery = @insertQuery + '''' + @stringValue + '''' + ','
								END
							ELSE
								BEGIN
									SET @insertQuery = @insertQuery + 'NULL' + ','
								END
					FETCH NEXT FROM dataCursor INTO @columnName, @dataType
				END
			SET @insertQuery = LEFT(@insertQuery, LEN(@insertQuery) - 1) + ')'
			EXEC (@insertQuery)
			SET @numberOfRows = @numberOfRows - 1
		END
	CLOSE dataCursor
	DEALLOCATE dataCursor
END