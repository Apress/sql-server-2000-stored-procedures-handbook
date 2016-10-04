EXEC master.DBO.sp_addlogin tester
EXEC pubs.DBO.sp_adduser tester
EXEC northwind.DBO.sp_adduser tester
EXEC sp_defaultdb tester, northwind
EXEC pubs.DBO.sp_addrole app
EXEC northwind.DBO.sp_addrole app

SELECT * INTO pubs.app.authors 
FROM pubs.DBO.authors
USE northwind
GO

CREATE VIEW app.vw_authors AS 
SELECT * FROM pubs.app.authors
GO
CREATE VIEW DBO.vw_authors AS 
SELECT * FROM pubs.DBO.authors
GO
GRANT SELECT ON app.vw_authors TO tester
GRANT SELECT ON DBO.vw_authors TO tester
