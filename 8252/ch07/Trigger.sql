----------------------------------------------------------------------------------------------
--Creation of a trigger and using its conceptual tables
----------------------------------------------------------------------------------------------

CREATE TRIGGER tr_upd_OrdersCount
ON orders
AFTER UPDATE
AS
BEGIN
  DECLARE @Rc VARCHAR(20)
  
  SELECT @Rc = CAST(COUNT(*) as VARCHAR(10)) FROM deleted
  SET @Rc = 'Rows Updated ' + @Rc
  RAISERROR(@Rc,1,1)
END

go

UPDATE orders
SET RequiredDate = RequiredDate
WHERE CustomerId = 'VINET'

