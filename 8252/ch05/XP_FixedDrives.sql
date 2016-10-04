CREATE TABLE #fixeddrives 
  (drive CHAR(1),
   MBFree INT
  )
INSERT #fixeddrives
EXECUTE xp_fixeddrives 
SELECT drive, MBFree FROM #fixeddrives
DROP TABLE #fixeddrives
