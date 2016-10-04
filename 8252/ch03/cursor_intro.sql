
--=================================================================================================
--  Uses of Cursors; Formatting Fields in a Result Set
--=================================================================================================

----------------------------------------------------------------------------------------------------
--As a cursor
----------------------------------------------------------------------------------------------------

--this code will give us all orders, the customer, and the
--total of each order

--first create our temp table
CREATE TABLE #holdOutput
  (
    orderId int primary key nonclustered,
    companyName nvarchar(40),
    orderTotal  money null
  )

--then go and fetch rows from database, with 
--only the columns that do not need formatting
INSERT INTO #holdOutput (orderId, companyName)

SELECT orders.orderId, customers.companyName
FROM orders
  join customers
  on orders.customerId = customers.customerId

--DECLARE our cursor which will contain the keys of #holdOutput table
DECLARE @outputCursor CURSOR
SET @outputCursor = CURSOR FAST_FORWARD FOR 
  SELECT orderId
  FROM #holdOutput

--open the cursor
OPEN @outputCursor

--variable to fetch into
DECLARE @orderId int

--fetch the first row from our cursor
FETCH FROM @outputCursor INTO @orderId
WHILE @@fetch_status = 0 
--loop until a fetch is invalid, in this 
--case past end of table
  BEGIN
  --update the total field
  UPDATE #holdOutput
  SET orderTotal = ( SELECT sum(unitPrice * quantity)
                     FROM [order details] 
                     WHERE orderId = @orderId
                    )
  WHERE orderId = @orderId
  --get the next row
  FETCH NEXT FROM @outputCursor INTO @orderId
  END

--get the output
SELECT * 
FROM #holdOutput

CLOSE @outputCursor
DEALLOCATE @outputCursor

DROP TABLE #holdOutput
go
----------------------------------------------------------------------------------------------------
--then build a function that does pretty much the same thing
----------------------------------------------------------------------------------------------------

CREATE FUNCTION order$returnTotal
  (
    @orderId int
  ) RETURNS money
AS
  BEGIN
    RETURN (SELECT sum(unitPrice * quantity)
            FROM [order details]
            WHERE orderId = @orderId
           )
  END
go
----------------------------------------------------------------------------------------------------
--and then our query would look like:
----------------------------------------------------------------------------------------------------

SELECT orders.orderId, customers.companyName,
  dbo.order$returnTotal(orders.orderId)
FROM orders
  join customers
  on orders.customerId = customers.customerId

--=================================================================================================
--  Uses of Cursors; Building a complex Result Set
--=================================================================================================


----------------------------------------------------------------------------------------------------
--showing how the rand function behaves.  The sum should average around 50, over several executes
----------------------------------------------------------------------------------------------------

declare @i int set @i = 1
declare @sum int set @sum = 0

while @i <= 100
 begin
	set @sum = @sum + ROUND(RAND(),0)
	set @i = @i + 1
 end
select @sum


----------------------------------------------------------------------------------------------------
--unfortunately, every row has the same random number output
----------------------------------------------------------------------------------------------------

SELECT ROUND(RAND(),0) as rand, employeeId
FROM northwind..employees



----------------------------------------------------------------------------------------------------
--The follow code 
----------------------------------------------------------------------------------------------------


CREATE TABLE #holdEmployees
  ( 
    employeeId int
  )

DECLARE @outputCursor cursor
SET @outputCursor = CURSOR FAST_FORWARD FOR 
  SELECT employeeId
  FROM   northwind..employees

--open the cursor
OPEN @outputCursor

--variable to fetch into
DECLARE @employeeId int

--fetch the first row from our cursor
FETCH FROM @outputCursor INTO @employeeId

WHILE @@fetch_status = 0 
--loop until a fetch is invalid, in this 
--case past end of table
  BEGIN
    INSERT INTO #holdEmployees (employeeId)
    SELECT @employeeId
    WHERE 1 = ROUND (RAND(),0)

    FETCH NEXT FROM @outputCursor INTO @employeeId
  END

--Once we have built the set, we run the SELECT query:

SELECT *
FROM northwind..employees
  JOIN #holdEmployees
  ON employees.employeeId = #holdEmployees.employeeId

DROP TABLE #holdEmployees
DROP TABLE #holdOutput