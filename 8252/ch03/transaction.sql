
--=================================================================================================
--  Transactions ; Simple Transactions
--=================================================================================================

----------------------------------------------------------------------------------------------------
--Marked Transactions
----------------------------------------------------------------------------------------------------

--this will work
BEGIN TRANSACTION one
ROLLBACK TRANSACTION one

--This will leave a transaction open

BEGIN TRANSACTION one
BEGIN TRANSACTION two
ROLLBACK TRANSACTION two

--clean up
rollback transaction
go

----------------------------------------------------------------------------------------------------
--Nesting Transactions
----------------------------------------------------------------------------------------------------
SELECT @@TRANCOUNT AS zeroDeep
BEGIN TRANSACTION
SELECT @@TRANCOUNT AS oneDeep
go

BEGIN TRANSACTION
SELECT @@TRANCOUNT AS twoDeep
COMMIT TRANSACTION
SELECT @@TRANCOUNT AS oneDeep

COMMIT TRANSACTION
SELECT @@TRANCOUNT AS zeroDeep
go

--only one rollback required
BEGIN TRANSACTION
BEGIN TRANSACTION
BEGIN TRANSACTION
BEGIN TRANSACTION
BEGIN TRANSACTION
BEGIN TRANSACTION
BEGIN TRANSACTION

select @@trancount as InTran

ROLLBACK TRANSACTION

select @@trancount as OutTran
go


----------------------------------------------------------------------------------------------------
--Savepoints
----------------------------------------------------------------------------------------------------

create table performer
(
	performerId	int identity,
	name		varchar(100)
)

begin transaction

insert into performer(name)
values ('Elvis Costello')

save transaction savePoint

insert into performer(name)
values ('Air Supply')

rollback transaction savePoint

commit transaction

select * from performer
go

----------------------------------------------------------------------------------------------------
-- More savepoints
----------------------------------------------------------------------------------------------------


--check the value of the customerId to start
select 	OrderId, CustomerId 
from 	northwind..orders 
where 	orderId = 10248

--start the transaction and set a savepoint
Begin Transaction
Save Transaction savepoint

--modify the value
UPDATE 	northWind..orders
SET	CustomerId = 'TOMSP'
WHERE	orderId = 10248

--check the value
select OrderId, CustomerId from northwind..orders where orderId = 10248

--rollback to the savepoint
Rollback transaction savepoint

--check the value again
select OrderId, CustomerId from northwind..orders where orderId = 10248

--close the transaction
COMMIT TRANSACTION


----------------------------------------------------------------------------------------------------
-- Executing code within a transaction and a procedure
----------------------------------------------------------------------------------------------------


CREATE PROCEDURE tranTest
AS
BEGIN
  SELECT @@TRANCOUNT AS trancount
  BEGIN TRANSACTION
  ROLLBACK TRANSACTION
END
 
--If we execute this procedure outside of a transaction, it is fine and returns a single row with a 0 value. 
--If however, we execute it as:

BEGIN TRANSACTION
EXECUTE tranTest
COMMIT TRANSACTION

--an error occurs

DROP  PROCEDURE tranTest
go
CREATE PROCEDURE tranTest
AS
BEGIN
  DECLARE @savepoint varchar(30)
  SET @savepoint = cast(object_name(@@procid) AS varchar(27)) + 
                   cast(@@nestlevel AS varchar(3))

  SELECT @savepoint AS savepointName, @@TRANCOUNT AS trancount
  BEGIN TRANSACTION
    SAVE TRANSACTION @savepoint 
  ROLLBACK TRANSACTION @savepoint
  COMMIT TRANSACTION
END


Go

---this won't raise an error
BEGIN TRANSACTION
EXECUTE tranTest
COMMIT TRANSACTION

