CREATE PROCEDURE ourjob$notification
  (@sendmail TINYINT = 0,
   @recipients VARCHAR(255) = NULL
  )

AS

-- check to see if we need to keep on going
IF NOT EXISTS (query to count rows to send off and determine if 
  notification is needed)
RETURN 0

DECLARE @query VARCHAR(8000)
IF @sendmail = 1 -- we're going to send mail
BEGIN
  -- check to make sure a good recipient was sent in
  IF @recipients IS NULL
  ...Handle the error and RETURN -1 

  -- recursively call itself with a @sendmail flag of 0 to go to the
  -- query portion of the procedure
  SELECT @query = EXEC ourjob$notification, 0, NULL
  Specify the subject and any other message you want to add; 
  Specify whether the query will be attached or included

  -- Call the XP_SENDMAIL proc
  EXEC master.dbo.xp_sendmail @recipients, @subject = @subject,
    @message = @message, @query = @query, @attachment = 'true',
    @width = 2000, @no_output = 'true'

-- make sure that the width is sufficient and @no_output is true
END
ELSE -- @sendmail = 0;
BEGIN
  Here you put the query logic to return a single record set
END
GO
