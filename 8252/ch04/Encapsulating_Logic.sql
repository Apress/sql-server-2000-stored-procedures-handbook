------------------------------------------------------------------------
--We need to create a hypothetical table for invoices. 
--This table contains information on the customer invoices 
--and the data payments received for them
------------------------------------------------------------------------

CREATE TABLE dbo.wrox_Invoice
(
  InvoiceID           CHAR(5) PRIMARY KEY,
  OrderID             INT REFERENCES Orders(OrderId) NOT NULL,
  InvoiceDate         DATETIME NOT NULL,
  DueDate             DATETIME NOT NULL,
  PaymentReceivedDate DATETIME NULL
)
go
-------------------------------------------------------------------------
--Inserting invoices into the table
-------------------------------------------------------------------------

  INSERT wrox_Invoice 
    SELECT '00001', 10643, DATEADD(MM,-5,GETDATE()),
      DATEADD(MM,-4,GETDATE()),NULL

  INSERT wrox_Invoice
    SELECT '00002', 10692, DATEADD(MM,-4,GETDATE()),
      DATEADD(MM,-3,GETDATE()),NULL  

To see the error, uncomment the following lines
  INSERT wrox_Invoice
    SELECT '00003', 10702, DATEADD(MM,-3,GETDATE()),
      DATEADD(MM,-2,GETDATE()),NULL

GO

-------------------------------------------------------------------------
-- Creation of a stored procedure that encapsulates the logic surrounding
-- the creation of orders for our application
-------------------------------------------------------------------------

CREATE PROCEDURE CreateNewOrder
  @CustomerID    NVARCHAR(5),
  @EmployeeID    INT,
  @RequiredDate  DATETIME
AS

  SET NOCOUNT ON
  DECLARE @UnpaidInvoices INT,@NewOrderID INT

  SELECT @UnpaidInvoices = COUNT(*)
  FROM wrox_Invoice i
    INNER JOIN Orders o ON i.OrderID = o.OrderID
  WHERE DueDate <= DATEADD(MM,-2,GETDATE())
        AND PaymentReceivedDate IS NULL
        AND o.CustomerID = @CustomerID

  IF @UnpaidInvoices > 2
  BEGIN
  --This will generate an error in our case
    RAISERROR('This order cannot proceed as the customer
              has too many unpaid invoices',16,1)
    RETURN 1

  END

  INSERT Orders(CustomerID, EmployeeID, OrderDate, RequiredDate)
  SELECT @CustomerID, @EmployeeID, GETDATE(), @RequiredDate

  SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate
  FROM dbo.Orders 
go

---------------------------------------------------------------------------------------------
--Execution of our stored procedure
---------------------------------------------------------------------------------------------

EXEC CreateNewOrder 'ANATR',6,'20030610'
go
EXEC CreateNewOrder 'ALFKI',6,'20030610'
go

----------------------------------------------------------------------------------------------



