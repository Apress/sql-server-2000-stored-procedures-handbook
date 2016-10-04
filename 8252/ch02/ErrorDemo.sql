CREATE PROCEDURE ErrorDemo

  @Key1    INT,
  @Key2   INT,
  @Key3    INT,
  @Value1  VARCHAR(255),
  @Value2  VARCHAR(255),
  @Value3  VARCHAR(255)

AS
SET NOCOUNT ON

UPDATE Table1 Set Col2=@Value1 WHERE Col1=@Key1

IF @@ERROR<>0
BEGIN
  PRINT 'Handle error here'
END

UPDATE Table2 Set Col2=@Value2 WHERE Col1=@Key2

IF @@ERROR<>0
BEGIN
  PRINT 'Handle error here'
END

UPDATE Table3 Set Col2=@Value3 WHERE Col1=@Key3

IF @@ERROR<>0
BEGIN
  PRINT 'Handle error here'
END
