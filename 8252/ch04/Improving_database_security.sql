
---------------------------------------------------------------------------------------------
--This procedure forces deletion of rows in the customer table by passing values 
--to it one by one through @CustomerID
---------------------------------------------------------------------------------------------

select * from Customers

go

CREATE PROCEDURE DeleteCustomer1 @OrderID INT
AS
  SET NOCOUNT ON

  DELETE Customers 
  WHERE OrderID=@OrderID

Exec DeleteCustomer1 1

go

select * from Customers

go

----------------------------------------------------------------------------------------------
--This procedure sets a status flag to indicate a deleted row instead of actually deleting it
----------------------------------------------------------------------------------------------

ALTER TABLE Customers ADD Deleted INT 

go  

CREATE PROCEDURE DeleteCustomer2 @OrderID varchar
AS
  SET NOCOUNT ON

  UPDATE Customers 
  SET Deleted=1
  WHERE OrderID=@OrderID

SET @OrderID = 1

EXEC DeleteCustomer2 'VINET'

select * from Customers where Deleted!=1

drop deleteCustomer1

select * from Customers