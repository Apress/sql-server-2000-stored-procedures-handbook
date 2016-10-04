----------------------------------------------------------------------------------------------
--AFTER trigger
----------------------------------------------------------------------------------------------

CREATE TABLE Orders_Audit (
  OrderID INT ,
  CustomerID NCHAR (5)  NULL ,
  EmployeeID INT NULL ,
  OrderDate DATETIME NULL ,
  RequiredDate DATETIME NULL ,
  ShippedDate DATETIME NULL ,
  ShipVia INT NULL ,
  Freight MONEY NULL ,
  ShipName NVARCHAR (40)  NULL ,
  ShipAddress NVARCHAR (60)  NULL ,
  ShipCity NVARCHAR (15)  NULL ,
  ShipRegion NVARCHAR (15)  NULL ,
  ShipPostalCode NVARCHAR (10)  NULL ,
  ShipCountry NVARCHAR (15) NULL ,
  DateAdded DATETIME NOT NULL DEFAULT GETDATE()
)

CREATE TRIGGER tr_iud_Orders
ON Orders
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
-- If either of these two dates altered, then create the audit record
-- If either are not altered, then no audit record 
IF UPDATE(ShippedDate) OR UPDATE(RequiredDate) THEN
INSERT INTO Orders_Audit (OrderID ,CustomerID ,EmployeeID ,OrderDate ,RequiredDate ,ShippedDate  ,ShipVia ,Freight ,ShipName ,ShipAddress ,ShipCity ,ShipRegion , 
    ShipPostalCode ,ShipCountry )
 
SELECT OrderID , CustomerID , EmployeeID , OrderDate , RequiredDate , 
  ShippedDate , ShipVia , Freight , ShipName , ShipAddress , 
    ShipCity , ShipRegion , ShipPostalCode , ShipCountry
  FROM deleted
END




