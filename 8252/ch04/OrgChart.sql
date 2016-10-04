USE Northwind
GO

CREATE TABLE EmployeeHierarchy

  (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    ManagerID INT REFERENCES Employees(EmployeeID)
  )


INSERT EmployeeHierarchy
SELECT TOP 1 
  EmployeeID,
  FirstName,
  LastName,
  NULL
FROM Employees e1
ORDER BY NEWID()

WHILE @@ROWCOUNT<>0
BEGIN
  INSERT EmployeeHierarchy
  SELECT   TOP 1
    EmployeeID,
    FirstName,
 

    LastName,
    (SELECT TOP 1 EmployeeID 
    FROM dbo.EmployeeHierarchy e2
    WHERE e1.EmployeeID <> e2.EmployeeID
    ORDER BY NEWID())
  FROM Employees e1
  WHERE e1.EmployeeID NOT IN 
     (SELECT EmployeeID FROM EmployeeHierarchy)
END


GO


CREATE PROCEDURE GetOrgChart
AS
  SET NOCOUNT ON

  CREATE TABLE #OrgChart
    (
      EmployeeID INT,
      EmpLevel   INT,
      FirstName  VARCHAR(20),
      LastName   VARCHAR(20)
    )
  DECLARE @Level INT

  SELECT @Level=1

  -- Insert our Boss
  INSERT  #OrgChart
  SELECT TOP 1 
         e.EmployeeID, @Level, e.FirstName, e.LastName
  FROM  EmployeeHierarchy e
  WHERE ManagerID IS NULL

  WHILE @@Rowcount>0
  BEGIN
    SELECT @Level=@Level+1

    INSERT  #OrgChart
    SELECT  e.EmployeeID, @Level, e.FirstName, e.LastName
    FROM  EmployeeHierarchy e
    INNER JOIN #OrgChart oc2
      ON e.ManagerID = oc2.EmployeeId 
 

    LEFT OUTER JOIN #OrgChart oc
      ON e.EmployeeID = oc.EmployeeId
    WHERE oc.EmployeeId IS NULL
  END

  SELECT * FROM #OrgChart ORDER BY EmpLevel

