SELECT OrderId, CustomerId, OrderDate, ShippedDate
FROM dbo.Orders 
WHERE ShippedDate > dbo.fn_AddWorkDays(10,OrderDate)

