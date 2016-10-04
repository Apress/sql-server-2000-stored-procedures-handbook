DECLARE @data_item_multi NVARCHAR(1000),@retcode INT
DECLARE @value_multi NVARCHAR(1000)
SELECT @data_item_multi = N'ItemX', @value_multi = N'MULTI'
EXECUTE @retcode = master.dbo.xp_regaddmultistring
                   N'HKEY_LOCAL_MACHINE', N'SOFTWARE\_Test',
                   @value_multi, @data_item_multi
SELECT @retcode
