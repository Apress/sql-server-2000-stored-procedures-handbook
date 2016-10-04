
----------------------------------------------------------------------------------------------
--A trigger will fire on the triggering action even if no rows have been affected
----------------------------------------------------------------------------------------------
CREATE TRIGGER tr_upd_OrdersNoRows
ON Orders
AFTER UPDATE
AS
BEGIN
  RAISERROR('Update occurred',1,1)
END

go

UPDATE Orders 
SET RequiredDate = Null
WHERE CustomerId = 'NOROW'

go

----------------------------------------------------------------------------------------------
--The correct method of writing a trigger is to use @@ROWCOUNT to check how many rows 
--were affected
----------------------------------------------------------------------------------------------

ALTER TRIGGER tr_upd_OrdersNoRows
ON Orders
AFTER UPDATE
AS
BEGIN
  IF @@ROWCOUNT = 0
    RETURN

  RAISERROR('Update occurred',1,1)

END

go

UPDATE Orders 
SET RequiredDate = Null
WHERE CustomerId = 'NOROW'

