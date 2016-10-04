--Make a key with only a default, blank value:
DECLARE @retcode INT
EXECUTE @retcode = master.dbo.xp_regwrite N'HKEY_LOCAL_MACHINE',
  N'SOFTWARE\_Test',
  N'', -- the default, non-named value
  N'REG_SZ',              -- the value type
  N''                     -- this is the blank data
SELECT @retcode


--For adding or changing a REG_DWORD value: 
DECLARE @intDWORD INT, @retcode INT
SELECT @intDWORD = 0
EXECUTE @retcode = master.dbo.xp_regwrite N'HKEY_LOCAL_MACHINE',
                   N'SOFTWARE\_Test', N'DWORD VALUE', N'REG_DWORD',
                   @intDWORD
SELECT @retcode


--For adding or changing a REG_SZ value:
DECLARE @value_string NVARCHAR(1000),@retcode INT
SELECT @value_string = 'Sample Value'
EXECUTE @retcode = master.dbo.xp_regwrite N'HKEY_LOCAL_MACHINE',
                   N'SOFTWARE\_Test', N'STRING VALUE', N'REG_SZ',
                   @value_string
SELECT @retcode


--Adding or changing a REG_BINARY value:
DECLARE @value_binary VARBINARY(1048),@retcode INT
SELECT @value_binary = 0x63657273
EXECUTE @retcode = master.dbo.xp_regwrite 
  'HKEY_LOCAL_MACHINE',
  N'SOFTWARE\_Test',
  N'BINARY VALUE',
  'REG_BINARY',
  @value_binary
SELECT @retcode
