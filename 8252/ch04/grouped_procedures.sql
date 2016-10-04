-------------------------------------------------------------------------------------------------
--Multiple stored procedures can be grouped together with a single name by specifying
--a group number at the time of creation
-------------------------------------------------------------------------------------------------

USE Northwind

GO

CREATE PROCEDURE GroupProcedure;1

AS

	SELECT COUNT(*) FROM Employees

GO

CREATE PROCEDURE GroupProcedure;2

AS

	SELECT COUNT(*) FROM Orders

GO

CREATE PROCEDURE GroupProcedure;3

AS

	SELECT COUNT(*) FROM Customers

GO

--We simply specify the procedure name followed by its number in the group, 
--or just the procedure name, to execute it

EXEC GroupProcedure -- Equivalent to EXEC GroupProcedure;1

EXEC GroupProcedure;1 -- Returns a COUNT(*) from Employees

EXEC GroupProcedure;2 -- Returns a COUNT(*) from Orders

EXEC GroupProcedure;3 -- Returns a COUNT(*) from Customers

DROP PROCEDURE GroupProcedure

--This statement will result in an error
--DROP PROCEDURE GroupProcedure;3

GO 

CREATE PROCEDURE GroupProcedure;3

AS

	SELECT COUNT(*) FROM Customers

GO

