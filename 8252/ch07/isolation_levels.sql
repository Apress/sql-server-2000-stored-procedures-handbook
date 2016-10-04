---------------------------------------------------------------------------------------------
--Run the following code in a connection and open a second connection to
--run read_uncommitted.sql/read_committed.sql
---------------------------------------------------------------------------------------------
CREATE TABLE IsoLvlTest 
(DescCol VARCHAR(10))

GO

INSERT INTO IsoLvlTest VALUES('Row 1')
INSERT INTO IsoLvlTest VALUES('Row 2')
INSERT INTO IsoLvlTest VALUES('Row 3')
INSERT INTO IsoLvlTest VALUES('Row 4')
INSERT INTO IsoLvlTest VALUES('Row 5')
INSERT INTO IsoLvlTest VALUES('Row 6')

GO

SELECT * FROM IsoLvlTest
BEGIN TRAN
UPDATE IsoLvlTest
SET DescCol = 'Update 1'
WHERE DescCol = 'Row 1'
WAITFOR DELAY '00:00:30'
ROLLBACK TRAN
SELECT * FROM IsoLvlTest
