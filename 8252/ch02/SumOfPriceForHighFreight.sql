CREATE PROCEDURE SumOfPriceForHighFreight
AS
  SELECT Sum(od.UnitPrice)
  FROM Orders o
  INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
  WHERE o.Freight > 1000
