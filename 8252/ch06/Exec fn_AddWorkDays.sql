SELECT dbo.fn_AddWorkDays(3,'2 Dec 2002')
Go

SELECT OrderId, CustomerId, RequiredDate
FROM dbo.Orders 
WHERE RequiredDate > dbo.fn_AddWorkDays(2,'3 March 1998')
Go

