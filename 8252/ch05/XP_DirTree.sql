CREATE TABLE #dirtree 
  (subdirectory NVARCHAR(1000),
   depth INT
  )
INSERT #dirtree
EXECUTE xp_dirtree N'c:\temp',1
SELECT subdirectory, depth FROM #dirtree
DROP TABLE #dirtree
