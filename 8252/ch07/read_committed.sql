
----------------------------------------------------------------------------------------------
--Start the isolation_levels.sql in the first connection and then run this one in the second connection
--Providing we do this within the 30 seconds, we see that we are locked out of processing this query 
--until the update completes
----------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
SELECT * FROM IsoLvlTest
----------------------------------------------------------------------------------------------
