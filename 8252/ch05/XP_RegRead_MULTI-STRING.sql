DECLARE @regvalue NVARCHAR(1000), @rc INT
DECLARE @regkey NVARCHAR(1000), @hive NVARCHAR(1000)
CREATE TABLE #regmultistring 
  (Item NVARCHAR(1000),
   Value NVARCHAR(1000)
  )

SELECT @hive = N'HKEY_LOCAL_MACHINE'
SELECT @regkey = N'SOFTWARE\_Test'
SELECT @regvalue = N'Multi'

EXECUTE @rc = master.dbo.xp_regread @hive, @regkey, @regvalue
SELECT Item,Value FROM #regmultistring
DROP TABLE #regmultistring
