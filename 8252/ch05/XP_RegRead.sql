DECLARE @data SQL_VARIANT, @regvalue NVARCHAR(1000), @rc INT
DECLARE @regkey NVARCHAR(1000), @hive NVARCHAR(1000)
SELECT @hive = N'HKEY_LOCAL_MACHINE'
SELECT @regkey = N'SOFTWARE\_Test'
SELECT @regvalue = N'String Value'

EXECUTE @rc = master.dbo.xp_regread @hive, @regkey, @regvalue,
        @data OUTPUT, N'no_output'
SELECT @rc,@data
