CREATE TABLE #fileexist 
  (FileExists BIT,
   FileIsDirectory BIT,
   ParentDirectoryExists BIT
  )
INSERT #fileexist 
EXECUTE xp_fileexist 'c:\windows'
SELECT * FROM #fileexist
DROP TABLE #fileexist
