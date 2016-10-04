USE master
GO
Exec sp_configure 'allow updates',1
GO
Reconfigure with override
GO
EXEC sp_MS_upd_sysobj_category 1
GO

CREATE PROCEDURE sp_test AS PRINT 'master'
GO

EXEC sp_MS_upd_sysobj_category 2
GO
Exec sp_configure 'allow updates',0
GO
Reconfigure with override
GO
