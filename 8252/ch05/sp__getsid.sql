CREATE PROCEDURE sp__getsid (@loginame sysname) 
-- Note: This procedure uses UNDOCUMENTED
-- functionality compatible with SQL 2000 SP2
AS
DECLARE @newsid VARBINARY(85)
SELECT @newsid = get_sid('\U'+@loginame, NULL)   -- NT user

IF @newsid IS NULL  -- the loginame is not a user
SELECT @newsid = get_sid('\G'+@loginame, NULL)   -- NT group

IF @newsid IS NOT NULL
BEGIN 
  SELECT @newsid 
  RETURN 0 
END
ELSE   -- the login is not a user or group
BEGIN
  SELECT 'No SID was available for '+ @loginame
  RETURN 1
END
