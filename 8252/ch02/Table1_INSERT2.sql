CREATE PROCEDURE Table1_INSERT
  @IDValue  int,
  @VarCharValue  varchar(255)
AS
SET NOCOUNT ON

  IF CheckIfSalesManager (Current_User)
  BEGIN

    INSERT dbo.Table1(IDCol,VarCharCol)
    VALUES(@IDValue, @VarCharValue)
  
  END
