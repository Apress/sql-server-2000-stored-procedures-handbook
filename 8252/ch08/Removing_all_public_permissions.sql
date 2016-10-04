SET NOCOUNT ON
-- We will loop through one record at a time
SET ROWCOUNT 1
DECLARE @i INT, @cmd VARCHAR(1000)
SELECT @i = 1
WHILE @i > 0
BEGIN
  SELECT @cmd = NULL
  -- u.name is the owner of object o.name
  SELECT @cmd = u.name+'.'+o.name
  FROM sysobjects o
  JOIN syspermissions p ON o.id = p.id
  JOIN sysusers u ON o.uid = u.uid
  WHERE p.grantee = 0  
-- public grantee UID is 0
  SELECT @i = @@rowcount
  -- the last time through @cmd IS NULL
  IF @cmd IS NOT NULL  
  BEGIN
    SELECT 'Revoking PUBLIC perm on '+@cmd
    EXEC ('revoke all on '+@cmd+' to public')
  END
END
