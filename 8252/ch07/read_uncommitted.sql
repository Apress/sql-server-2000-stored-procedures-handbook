----------------------------------------------------------------------------------------------
-- Start the isolation_levels.sql in the first connection and then run this one in the second connection
--Providing we do this within the 30 seconds, we will see that the first row has Update 1 as its value
----------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
SELECT * FROM IsoLvlTest

----------------------------------------------------------------------------------------------