CREATE PROCEDURE RAISERRORTest
  @IDCol  int

AS
  DECLARE @ErrorString VARCHAR(8000),
	  @ErrorValue INT

  IF OBJECT_ID('dbo.RAISERRORTestTable') IS NULL
  BEGIN
    CREATE TABLE dbo.RAISERRORTestTable
      (
        IDCOL  int PRIMARY KEY
       )
  END

  INSERT dbo.RAISERRORTestTable(IDCol) VALUES(@IDCol)
  SELECT @ErrorValue = @@ERROR

  IF @ErrorValue<>0
  BEGIN    
    SELECT @ErrorString='The following error has occured: ' + 
                         CAST(@ErrorValue AS VARCHAR(8))
    RAISERROR( @ErrorString,16,1)
  END
