ALTER PROCEDURE ErrorDemo

  @Key1    INT,
  @Key2   INT,
  @Key3    INT,
  @Value1  VARCHAR(255),
  @Value2  VARCHAR(255),
  @Value3  VARCHAR(255)

AS
SET NOCOUNT ON

DECLARE @ErrorValue INT

UPDATE Table1 Set Col2=@Value1 WHERE Col1=@Key1

IF @@ERROR<>0
  SELECT @ErrorValue=@@ERROR

UPDATE Table2 Set Col2=@Value2 WHERE Col1=@Key2

IF @@ERROR<>0
  SELECT @ErrorValue=@@ERROR

UPDATE Table3 Set Col2=@Value3 WHERE Col1=@Key3

IF @@ERROR<>0
  SELECT @ErrorValue=@@ERROR

IF @ErrorValue<>0
BEGIN
  PRINT 'Generically handle error'
END
