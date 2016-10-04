CREATE PROCEDURE xp_sendmail 
  (@recipients VARCHAR(8000) = NULL,
   @message VARCHAR(8000) = NULL,
   @query VARCHAR(8000) = NULL,
   @attachments VARCHAR(8000) = NULL,
   @copy_recipients VARCHAR(8000) = NULL,
   @blind_copy_recipients VARCHAR(8000) = NULL,
   @subject VARCHAR(8000) = NULL,
   @type VARCHAR(255) = NULL,
   @attach_results VARCHAR(5) = 'FALSE',
   @no_output VARCHAR (5) = 'FALSE',
   @no_header VARCHAR(5) = 'FALSE',
   @width INT = 80,
   @separator CHAR(1) = ' ',
   @echo_error VARCHAR(5) = 'FALSE',
   @set_user VARCHAR(255) = NULL,
   @dbuse SYSNAME = 'MASTER'
  )

/*
Purpose: Replaces xp_sendmail with a same name wrapper around xp_smtp_sendmail procedure; use when Exchange is not availble.

Version: 1.0
Author: C.Hawkins*/

AS
SET NOCOUNT ON

DECLARE @cmd VARCHAR(4000), 
  @PRIORITY NVARCHAR(10),
  @SERVER NVARCHAR(4000), 
  @RC INT, 
  @messagefile VARCHAR(8000),
  @outfile VARCHAR(255),
  @infile VARCHAR(255),
  @marker VARCHAR(255)

IF @recipients IS NULL
BEGIN
  RAISERROR('No Recipient was given.',16,-1)
  RETURN -1
END

-- Check to see if there is a query to run
IF @query IS NOT NULL
BEGIN -- @query IS NOT NULL
  -- set up an ISQL outfile; form of outfile is
  -- ISQLYYYYMMDDHHMISSMMM.OUT
  SELECT @marker = 'c:\temp\ISQL'+REPLACE(convert(varchar(32),
    GETDATE(),102),'.','') + 
    REPLACE(CONVERT(VARCHAR(32),GETDATE(),114),':','')
  SELECT @infile = @marker + '.sql'
  SELECT @outfile = @marker + '.out'

  -- write the query out to the infile because it makes it easier to
  -- deal with single quotes
  SELECT @cmd = 'echo '+@query+ ' >'+@infile
  EXEC @RC = master.dbo.xp_cmdshell @cmd,no_output

  IF @RC <> 0
  BEGIN
    RAISERROR('Error writing @infile for xp_sendmail',16,-1)
    RETURN -2
  END  -- @query IS NOT NULL

  -- build the ISQL command line
  SELECT @cmd = '"C:\Program Files\Microsoft SQL Server\80\Tools\Binn\
                 isql.exe" -E -n -b -d '+@dbuse+' -t 600 -h'+
                 CASE WHEN @no_header = 'TRUE' THEN '-1' ELSE ' 0' END
                 + ' -w'+CONVERT(VARCHAR(10),@width)+ CASE WHEN 
                 LTRIM(@separator) <> '' THEN ' -s '+@separator ELSE 
                 '' END + CASE WHEN @echo_error = 'TRUE' THEN ' -e' 
                 ELSE '' END + ' -i '+ @infile+ ' -o '+@outfile

  -- Execute the ISQL command line
  EXEC @RC = master.dbo.xp_cmdshell @cmd,no_output
  IF @RC <> 0
  BEGIN
    RAISERROR('Error running ISQL for @query',16,-1)
    RETURN -3
  END

  IF @attach_results = 'FALSE' 
  BEGIN
    SELECT @messagefile = @outfile
    IF @attachments IS NULL
    BEGIN
      SELECT @attachments = ''
    END
  END
  -- The output file will be one of the attachments
  ELSE
  BEGIN
    SELECT @messagefile = ''
    IF @attachments IS NULL
    BEGIN
      SELECT @attachments = @outfile
    END
    ELSE
    BEGIN
      SELECT @attachments = @attachments + ';' + @outfile
    END
  END
END 

IF @message IS NULL SELECT @message = ''
IF @query IS NULL SELECT @query = ''
IF @attachments IS NULL SELECT @attachments = ''
IF @copy_recipients IS NULL SELECT @copy_recipients = ''
IF @blind_copy_recipients IS NULL SELECT @blind_copy_recipients = ''
IF @subject IS NULL SELECT @subject = ''

EXEC @rc = master.dbo.xp_smtp_sendmail
@FROM = @@servername,
@TO = @recipients,
@CC = @copy_recipients,
@BCC = @blind_copy_recipients,
@priority = NORMAL,
@subject = @subject,
@message = @message,
@messagefile = @messagefile,  
@type = 'text/plain',
@attachments = @attachments

IF @RC <> 0
BEGIN
  RAISERROR('Error sending mail for xp_smtp_sendmail',16,-1)
  RETURN -4
END

-- temporary: set @marker to NULL to save the files; comment out in 
-- production.
-- select @marker = NULL

-- clean up the temp files from @query
IF @marker IS NOT NULL
BEGIN
  SELECT @cmd = 'del '+@marker+'.* /Q'
  EXEC master.dbo.xp_cmdshell @cmd,no_output
END
GO
