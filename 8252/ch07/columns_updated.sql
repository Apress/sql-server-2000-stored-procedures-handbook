
---------------------------------------------------------------------------------------------
--Using the COLUMNS_UPDATED() function to output OrderID or the whole table 
--depending on the columns updated
---------------------------------------------------------------------------------------------

select * from Orders where customerid='VINET'

go

UPDATE orders
SET RequiredDate = RequiredDate
WHERE CustomerId = 'VINET'

IF (COLUMNS_UPDATED()&82) = 1
SELECT * from Orders
else select OrderID from Orders

--This outputs the whole table as the RequiredDate is the 5th column, for which we have set the bitmask

go

UPDATE orders
SET RequiredDate = RequiredDate
WHERE CustomerId = 'VINET'

IF SUBSTRING(COLUMNS_UPDATED(),1,1) = POWER(2,4-1) + POWER(2,7-1)
AND SUBSTRING(COLUMNS_UPDATED(),2,1) = POWER(2,10-8-1) + POWER(2,12-8-1)
select * from orders
else select OrderID from Orders

--This outputs the whole table as the RequiredDate is the 5th column, for which we not have set 
--the bitmask. We have set the bitmask for the 11th, 13th and 15th columns.

