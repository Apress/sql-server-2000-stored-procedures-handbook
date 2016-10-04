--------------------------------------------------------------------------
--An example of a simple stored procedure follows, where two numbers are 
--passed in and the midpoint of the two numbers is listed
--------------------------------------------------------------------------

CREATE PROCEDURE ut_MidPoint @LowerNumber int, @HigherNumber int
AS
BEGIN

  DECLARE @Mid int
  IF @LowerNumber > @HigherNumber
    RAISERROR('You have entered your numbers the wrong way around',16,1)

  SET @Mid = ((@HigherNumber - @LowerNumber) / 2) + @LowerNumber

  SELECT @Mid
END

GO
-------------------------------------------------------------------------
--In the following snippet, we have two similar stored procedures. 
--The difference is in the use of the BEGIN … END code block.

CREATE PROCEDURE ut_NoBeginEnd
AS
BEGIN
  DECLARE @var1 int, @var2 int
  SET @var1 = 1
  SET @var2 = 2
  IF @var1 = @var2
    PRINT @var1
  PRINT @var2
END

GO
--Executing the first one will execute the second PRINT statement, 
--as the IF statement will take only the first line as part of the decision

CREATE PROCEDURE ut_BeginEnd
AS
BEGIN

  DECLARE @var1 int, @var2 int
  SET @var1 = 1
  SET @var2 = 2
  IF @var1 = @var2
  BEGIN
    PRINT @var1
    PRINT @var2
  END
END

GO
--------------------------------------------------------------------------
--The following code demonstates two snippets.

DECLARE @AvgFound Money

SELECT @AvgFound = AVG(UnitPrice) FROM [Order Details]

IF @AvgFound < 10
  Print 'Less than 10'
ELSE
  Print 'More than 10'

GO

--The first statement works faster, as a simple SELECT statement
--takes the table and processes the data

IF (SELECT AVG(UnitPrice) FROM [Order Details]) < 10
  Print 'Less than 10'
ELSE
  Print 'More than 10'

GO

--------------------------------------------------------------------------
--Demonstrating CASE statements
--------------------------------------------------------------------------

CREATE PROCEDURE ut_CASE_with_SELECT
AS
BEGIN
  
SELECT OrderId, Discount, 
CASE Discount
WHEN 0 THEN 'No Discount'
WHEN (SELECT MAX(Discount) FROM [Order Details]) THEN 'Top Discount'
ELSE 'Average'
END AS Disc
FROM [order details]
 
END 

GO

--------------------------------------------------------------------------
--The NULL values problems CASE statements
--------------------------------------------------------------------------

CREATE PROCEDURE ut_CASE_NULL_NotWorking
AS
BEGIN
   
SELECT CompanyName, Phone,
CASE Fax
WHEN NULL THEN 'No Fax'
ELSE Fax
END AS Fax
FROM Customers

END  

GO

---------------------------------------------------------------------------
--solving the NULL values problem
---------------------------------------------------------------------------

CREATE PROCEDURE ut_CASE_With_Null
AS
BEGIN
   
SELECT CompanyName, Phone,
CASE 
WHEN FAX Is NULL THEN 'No Fax'
ELSE Fax
END AS Fax
FROM Customers

END 

GO

--------------------------------------------------------------------------
--An example of Looping 
--------------------------------------------------------------------------

CREATE PROCEDURE ut_WhileLoop
AS
BEGIN
  DECLARE @var1 int, @var2 int

  SET @var1 = 1
  SET @var2 = 1
  WHILE @var1 < 10
  BEGIN
    IF @var2 > 100
      BREAK
    SET @var2 = @var2 + @var2
    SET @var1 = @var1 + 1
  END
  PRINT 'Var1=' + CONVERT(CHAR(3),@var1) + ' and Var2=' +
  CONVERT(CHAR(3),@var2)

END

GO

--------------------------------------------------------------------------
--Nested Stored Procedures
--------------------------------------------------------------------------

CREATE PROCEDURE ut_Factorial @ValIn bigint, @ValOut bigint output
AS
BEGIN
  IF @ValIn > 20
  BEGIN
    PRINT 'Invalid starting point. Has to be <= 20'
    RETURN -99
  END

  DECLARE @WorkValIn bigint, @WorkValOut bigint

  IF @ValIn != 1
    BEGIN
      SET @WorkValIn = @ValIn - 1
      PRINT @@NESTLEVEL
      EXEC ut_Factorial @WorkValIn, @WorkValOut OUTPUT
      SET @ValOut = @WorkValOut * @ValIn
    END
  ELSE
    SET @ValOut = 1

END

GO
---------------------------------------------------------------------------
--to check that we do not have more than a 20 level recursion invoked by 
--the test at the top of the procedure

DECLARE @FactIn int, @FactOut int
SET @FactIn = 8
EXEC ut_Factorial @FactIn, @FactOut OUTPUT

PRINT 'Factorial of ' + CONVERT(varchar(3),@FactIn) + ' is ' +
       CONVERT(varchar(20),@FactOut)

GO

----------------------------------------------------------------------------
--Returning values from stored procedures
--A procedure that runs against the Categories table in northwind and 
--returns the rows from the table and the number of rows found
----------------------------------------------------------------------------

CREATE PROCEDURE sel_Categories
AS
BEGIN
  DECLARE @Rc INT
  SELECT CategoryName, Description
  FROM Categories
  
  SET @Rc = @@ROWCOUNT
  
  RETURN @Rc
  -- Any statement here will not execute
END

GO

--to execute this statement in the Query Analyzer

DECLARE @RcRet INT
EXEC @RcRet = sel_Categories
SELECT @RcRet "No. Rows"

GO

---------------------------------------------------------------------------
--Defining an output parameter in a stored procedure
---------------------------------------------------------------------------
CREATE PROCEDURE sel_CategoriesWithOutput @Rcnt INT OUTPUT
AS
BEGIN
  SELECT CategoryName, Description
  FROM Categories
  
  SET @Rcnt = @@ROWCOUNT
  
  RETURN 1
  -- Any statement here will not execute
END

GO

--To execute this stored procedure, we define the return code variable
--but also define the output parameter with the OUTPUT keyword

DECLARE @OutParm INT, @RetVal INT
EXEC @RetVal = sel_CategoriesWithOutput @OutParm OUTPUT
SELECT @OutParm "Output Parm", @RetVal "Return Value"














