CREATE TABLE #values 
  (value NVARCHAR(1000) NULL,
   data NVARCHAR(1000) NULL
  )

EXECUTE xp_regenumvalues N'HKEY_LOCAL_MACHINE', N'SOFTWARE\_Test'
SELECT value,data FROM #values
DROP TABLE #values
