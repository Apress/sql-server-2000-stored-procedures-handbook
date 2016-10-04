CREATE FUNCTION fn_EmpName (@EmpID INT)
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @NewName VARCHAR(50)
  SELECT @NewName = RTRIM(TitleOfCourtesy) + ' ' + LEFT(FirstName,1) +
    '. ' + RTRIM(LastName)
  FROM dbo.Employees
  WHERE EmployeeID = @EmpID
  RETURN @NewName
END
