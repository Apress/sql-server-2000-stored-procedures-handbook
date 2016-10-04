
USE master
GO
CREATE PROCEDURE sp_test AS PRINT 'master'
GO

USE pubs
GO
CREATE PROCEDURE sp_test AS PRINT 'pubs'
GO
