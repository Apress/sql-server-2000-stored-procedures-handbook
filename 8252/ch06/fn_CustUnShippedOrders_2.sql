CREATE FUNCTION fn_CustUnShippedOrders (@CustId NCHAR(5))
RETURNS TABLE
AS
RETURN (SELECT o.CustomerId, o.OrderDate, o.RequiredDate,
        s.CompanyName AS 'Shipper',ROUND(
        SUM((UnitPrice * Quantity) - Discount),2) AS 'Order Value'
       FROM dbo.Orders o
        JOIN dbo.[Order Details] d ON o.OrderId = d.OrderId
        JOIN dbo.Shippers s ON o.ShipVia = s.ShipperId
       WHERE o.ShippedDate IS NULL 
        AND (@CustId IS NULL OR o.CustomerId = @CustId)
       GROUP BY customerid,o.OrderDate, o.RequiredDate, s.CompanyName)

