CREATE FUNCTION fn_OrderShipDays (@NoDays INT, @OrderId INT)
RETURNS DATETIME
AS
BEGIN
  DECLARE @Today DATETIME

  SELECT @Today = OrderDate
  FROM dbo.Orders
  WHERE OrderId = @OrderId

  WHILE @NoDays > 0
  BEGIN
    IF DATEPART(dw,@Today) = 6
    SET @Today = DATEADD(day,3,@Today)
    ELSE
    SET @Today = DATEADD(day,1,@Today)

    SET @NoDays = @NoDays - 1
  END
  RETURN @Today
END
