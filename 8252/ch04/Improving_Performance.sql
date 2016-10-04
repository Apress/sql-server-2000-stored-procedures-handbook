create database temp 
use temp

CREATE TABLE Employees

  (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    ManagerID INT REFERENCES Employees(EmployeeID)
  )
go

CREATE PROCEDURE GetOrgChart
AS
  SET NOCOUNT ON

  CREATE TABLE #OrgChart
    (
      EmployeeID INT,
      EmpLevel   INT,
      ManagerID  INT
    )
  DECLARE @Level INT

  SELECT @Level=0

  WHILE @@Rowcount>0
  BEGIN
    SELECT @Level=@Level+1
   
    INSERT #OrgChart
    SELECT  EmployeeID, @Level, ManagerID
    FROM  Employees e
    LEFT OUTER JOIN #OrgChart oc
      ON e.EmployeeID = oc.EmployeeID
    WHERE oc.EmployeeID IS NULL
  END

go

EXEC GetOrgChart 

  SELECT * FROM #OrgChart ORDER BY EmpLevel

