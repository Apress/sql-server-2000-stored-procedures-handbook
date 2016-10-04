CREATE PROCEDURE TestDataGenerator
AS

  DECLARE @count INT

  IF OBJECT_ID('dbo.TestDataTable') IS NULL
  BEGIN
    CREATE TABLE dbo.TestDataTable
    (
      IDCOL INT PRIMARY KEY,
      VarCharCol  VARCHAR(255)
    )
  END

  SELECT @count=1

  WHILE @count<100
  BEGIN
    INSERT TestDataTable(IDCOL, VarCharCol)
    SELECT  @count,
      REPLICATE(CHAR((@count%26)+65),@count%255)
    SELECT @count=@count+1
  END
Go

EXEC TestDataGenerator
