DECLARE @errorlognumber TINYINT, @retcode INT
DECLARE @filename VARCHAR(255)
DECLARE @searchstring1 VARCHAR(255)
DECLARE @searchstring2 VARCHAR(255)
CREATE TABLE #filerows 
  (ident INT IDENTITY, 
   line VARCHAR(256),
   continuationRow INT
  )

SELECT @errorlognumber = 1
SELECT @filename = 'C:\Temp\hosts'
SELECT @searchstring1 = ''  -- returns non-blank lines with a space
SELECT @searchstring2= 'the'

-- searches for the three characters 'the' in a line
INSERT #filerows (line, continuationRow)
EXECUTE @retcode = xp_readerrorlog @errorlognumber, @filename,
                   @searchstring1, @searchstring2

SELECT line, continuationRow FROM #filerows
  ORDER BY ident
DROP TABLE #filerows
