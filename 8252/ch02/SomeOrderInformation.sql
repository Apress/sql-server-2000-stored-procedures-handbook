CREATE PROCEDURE SomeOrderInformation
AS
  SELECT Count(*)
  FROM Orders o
  INNER JOIN [Order Details] od ON o.OrderID=od.OrderID
  WHERE od.UnitPrice > 50

  SELECT COUNT(*)
  FROM Orders o
  WHERE o.Freight < 1000
