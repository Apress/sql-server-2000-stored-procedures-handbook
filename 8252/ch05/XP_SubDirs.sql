DECLARE @parentdir NVARCHAR(4000)
SELECT @parentdir = N'c:\temp'
EXEC xp_subdirs @parentdir
