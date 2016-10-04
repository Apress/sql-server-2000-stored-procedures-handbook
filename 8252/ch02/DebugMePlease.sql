CREATE PROCEDURE DebugMePlease
  @NoOfCustomers  INT
AS
SET NOCOUNT ON

DECLARE @CustomerCount INT

SELECT @CustomerCount=Count(*)
FROM Customers

IF @CustomerCount>@NoOfCustomers
BEGIN
  SELECT * 
  FROM Orders O
  INNER JOIN [Order Deals] od ON o.Orderid=od.Orderid
END
