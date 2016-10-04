DECLARE @retcode INT
EXECUTE @retcode = master.dbo.xp_RegDeleteValue N'HKEY_LOCAL_MACHINE',
                   N'SOFTWARE\_Test', N'Multi'
SELECT @retcode
