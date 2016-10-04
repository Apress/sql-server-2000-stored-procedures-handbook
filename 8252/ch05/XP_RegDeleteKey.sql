CREATE TABLE #keyexist (keyexist INT)
DECLARE @regkey NVARCHAR(1000), @keyexist INT, @retcode INT

-- regdelete returns 'Access Denied' message if key does not exist;
-- check before delete
SELECT @regkey = N'SOFTWARE\_Test'
INSERT INTO #keyexist EXECUTE master.dbo.xp_regread 
                              'HKEY_LOCAL_MACHINE', @regkey

SELECT @keyexist = keyexist FROM #keyexist
IF @keyexist = 1
BEGIN
  EXECUTE @retcode = master.dbo.xp_regdeletekey 'HKEY_LOCAL_MACHINE',
                     @regkey
  IF @@error <> 0 OR @retcode <> 0
  BEGIN
    SET @retcode = 1
    GOTO FAILURE
  END 
END
FAILURE:
DROP TABLE #keyexist
