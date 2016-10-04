CREATE TABLE #keyexist (keyexist INT)
DECLARE @regkey NVARCHAR(1000), @hive NVARCHAR(1000),@keyexist INT
SELECT @hive = 'HKEY_LOCAL_MACHINE'
SELECT @regkey = N'SOFTWARE\_Test'
INSERT INTO #keyexist 
EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @regkey
SELECT @keyexist = keyexist FROM #keyexist
IF @keyexist = 1
... -- continue with your code once you determine key exists
