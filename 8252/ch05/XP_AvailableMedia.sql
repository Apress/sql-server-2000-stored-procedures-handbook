SET NOCOUNT ON
CREATE TABLE #availablemedia 
  (name CHAR(3),
   [low free] INT, 
   [high free] INT, 
   [media type] TINYINT
  )
DECLARE @mediabitmap TINYINT
SELECT @mediabitmap = 255
INSERT #availablemedia
EXECUTE xp_availablemedia @mediabitmap

SELECT name, [low free], [high free],
  (CAST((CASE when [low free] >= 0 THEN [high free]
  else [high free] + 1 END) AS FLOAT) * 4294967296.0 + 
  cast([low free] as float))/1048576.0 AS 'Available MBytes',
CASE WHEN [Media Type] = 2 THEN 'Fixed Disk'
WHEN [Media Type] = 8 THEN 'CDROM'
WHEN [Media Type] = 1 THEN 'Floppy'
ELSE 'Unknown Media Type' END AS 'Media Type'
FROM #availablemedia
DROP TABLE #availablemedia
