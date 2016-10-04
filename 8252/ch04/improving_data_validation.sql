
-------------------------------------------------------------------------------------------------
--We should not be allowed to place an order for more items than available, 
--and should be able to enter an order only if there is enough quantity. 
--Hence we create a corresponding procedure that performs the data validation
-------------------------------------------------------------------------------------------------

--First we add some details of the [Order Details] table into Orders for easy computing

alter table [orders] add ProductID int
GO
update orders set productID= [order details].productID from [order details]
where orders.orderID=[order details].orderID
go
alter table [orders] add Quantity int
go
update orders set Quantity = [order details].Quantity from [order details]
where orders.orderID=[order details].orderID
go

alter table orders drop constraint FK_Orders_Customers
-- We drop this key since it may conflict with our insert, and presently we do not need it.

create table stock (stockonhand int, productid int)
go
insert into stock values (10, 72)
insert into stock values (60, 65)
insert into stock values (10, 51)
insert into stock values (60, 60)
insert into stock values (10, 49)
insert into stock values (60, 74)
insert into stock values (10, 77)
insert into stock values (10, 59)
insert into stock values (60, 32)
insert into stock values (10, 37)
insert into stock values (10, 70)
insert into stock values (60, 35)
------------------------------------------------------------------------------------------------
go

CREATE PROCEDURE AddNewOrder
 @CustomerID AS INT,
 @ProductID AS INT,
 @Quantity AS INT
AS
 SET NOCOUNT ON

BEGIN TRANSACTION

--If there is enough stock, then the order is created, the stock is reduced,
--and the transaction is committed.

SELECT StockOnHand FROM Stock WITH (UPDLOCK) 
WHERE ProductID= 72 --@ProductID

IF (SELECT StockOnHand FROM Stock WITH (UPDLOCK) 
WHERE ProductID=@ProductID) >=@Quantity
BEGIN
  INSERT orders(CustomerID, ProductID, Quantity)
  VALUES(@CustomerID, @ProductID, @Quantity)

  UPDATE STOCK
   SET StockOnHand = StockOnHand - @Quantity
  WHERE ProductID = @ProductID

  COMMIT TRANSACTION
END

--If there is not enough stock, an error is generated and the transaction is rolled back

ELSE
BEGIN
  RAISERROR('There is not enough stock to add this order',16,1)
  ROLLBACK TRANSACTION
END

GO

--Now we execute our procedure and find that it reject the order when the order exceeds stock

EXEC AddNewOrder 40, 72, 100
go

--This one executed since we have enough stock
EXEC AddNewOrder 40, 65, 10
