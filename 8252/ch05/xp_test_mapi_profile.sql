DECLARE @rc int, @profilename sysname
SET @profilename = @@servername

-- If you profile name isn't your server name, you need to adjust 
EXEC @rc = master.dbo.xp_test_mapi_profile @profilename 
IF @rc = 0
  Run XP_SENDMAIL
ELSE -- you have an error condition with your MAPI Server
  Try running a Net Send to one of your DBA's with XP_CMDSHELL
