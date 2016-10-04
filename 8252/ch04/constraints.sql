
------------------------------------------------------------------------------------------------
--We can see that the Products table has a constraint defined on it as [CK_Products_UnitPrice] CHECK ([UnitPrice] >= 0)
------------------------------------------------------------------------------------------------

CREATE PROCEDURE UpdateAllPrices @PriceReduction money
AS
UPDATE Products
 SET UnitPrice=UnitPrice-@PriceReduction

go

ALTER PROCEDURE UpdateAllPrices @PriceReduction money
AS
IF (Select Count(*) FROM Products 
    WHERE UnitPrice-@PriceReduction<=0) >0
  BEGIN
    RAISERROR('Price change will result in some free products',16,1)
  END
ELSE
  BEGIN
    UPDATE Products
    SET UnitPrice=UnitPrice-@PriceReduction
  END
 
go

--This will result in an error if the pricereduction of $10 will result in free products
exec UpdateAllPrices 10

