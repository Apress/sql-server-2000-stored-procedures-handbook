SELECT c.CompanyName, f.OrderDate, f.RequiredDate, 
  f.Shipper, f.[Order Value]
FROM dbo.Customers c
JOIN fn_CustUnShippedOrders(NULL) f ON f.CustomerId = c.CustomerId
