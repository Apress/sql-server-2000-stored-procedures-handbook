CREATE FUNCTION fn_AddWorkDays (@NoDays INT)
RETURNS DATETIME
AS
BEGIN

  DECLARE @Today DATETIME
  SET @Today = GETDATE()

  -- This should not happen but just in case the function is
  --called on a weekend 
  IF DATEPART(dw,@Today) IN (1,7)
  RETURN NULL

  --Main Part of the function
  WHILE @NoDays > 0
  BEGIN
    IF DATEPART(dw,@Today) = 6
    SET @Today = DATEADD(day,3,@Today)
    ELSE
    SET @Today = DATEADD(day,1,@Today)

    SET @NoDays = @NoDays - 1
  END
  RETURN @Today
END
