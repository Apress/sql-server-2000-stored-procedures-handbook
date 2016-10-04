DECLARE @fileexists INT
EXECUTE xp_fileexist 'c:\windows\explorer.exe', @fileexists OUTPUT
SELECT @fileexists

