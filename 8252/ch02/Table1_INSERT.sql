CREATE PROCEDURE Table1_INSERT
  @IDValue INT,
  @VarCharValue VARCHAR(255)
AS
SET NOCOUNT ON

  INSERT dbo.Table1(IDCol,VarCharCol)VALUES(@IDValue, @VarCharValue)
