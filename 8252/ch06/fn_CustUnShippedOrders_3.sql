CREATE FUNCTION fn_CustUnShippedOrders (@CustId NCHAR(5))
RETURNS @UnShipped TABLE (CustomerId NCHAR(5),
                          OrderDate DATETIME NULL, 
                          RequiredDate DATETIME NULL,
                          Shipper NVARCHAR(40),
                          [Order Value] MONEY
                         )
AS
BEGIN
  INSERT INTO @UnShipped
  SELECT o.CustomerId, o.OrderDate, o.RequiredDate, s.CompanyName AS
    'Shipper', ROUND(SUM((UnitPrice * Quantity) - Discount),2) AS 
    'Order Value'
  FROM dbo.Orders o
    JOIN dbo.[Order Details] d ON o.OrderId = d.OrderId
    JOIN dbo.Shippers s ON o.ShipVia = s.ShipperId
  WHERE o.ShippedDate IS NULL
    AND (@CustId IS NULL OR o.CustomerId = @CustId)
  GROUP BY customerid,o.OrderDate, o.RequiredDate, s.CompanyName
RETURN
END
