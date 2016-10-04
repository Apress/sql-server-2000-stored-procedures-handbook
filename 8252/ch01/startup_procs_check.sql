-------------------------------------------------------------------------
--To scan for startup procedures
-------------------------------------------------------------------------

sp_configure 'scan for startup procs',1

--if this does not work then run
--EXEC sp_configure 'show advanced option',1
--GO
--RECONFIGURE
--and set this option to 1
