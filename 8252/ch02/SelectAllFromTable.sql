CREATE PROCEDURE SelectAllFromTable
  @TableName  VARCHAR(255)
AS
  SET NOCOUNT ON
  DECLARE @SQLString VARCHAR(8000)
  SELECT @SQLString='SELECT * FROM ' + @TableName

Go

EXEC SelectAllFromTable 'Orders'
