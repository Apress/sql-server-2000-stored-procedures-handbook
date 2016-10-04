DECLARE @regkey NVARCHAR(1000), @retcode INT
CREATE TABLE #keylist (key_name NVARCHAR(1000))
SET @regkey = 'SOFTWARE'
INSERT INTO #keylist 
EXECUTE @retcode = master.dbo.xp_regenumkeys 
'HKEY_LOCAL_MACHINE', @regkey
SELECT @retcode
SELECT key_name FROM #keylist
DROP TABLE #keylist
