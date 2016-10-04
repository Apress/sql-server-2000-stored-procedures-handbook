-- This job puts the objects in the master database. You may want to place
-- the objects in a different database.
-- ----------------------------------------------------------------------------
-- NOTE: This job will not work if you are not auditing successful SQL logins
-- Go into Properties for the SQL Server in SQL Enterprise Manager. Go to 
-- the security tab. Audit either Success or All (recommended) logins.
-- ----------------------------------------------------------------------------
-- The job is set up to send email to your_email@company.com. Change it to 
-- a suitable email address.
-- ----------------------------------------------------------------------------
USE master
go

/****** Object:  Table [dbo].[login_notify_perm]    Script Date: 2/23/2001 12:07:18 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[login_notify_perm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [login_notify_perm]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[login_notify_perm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
 BEGIN
CREATE TABLE [login_notify_perm] (
	[login__time] [datetime] NOT NULL ,
	[sp_id] [smallint] NOT NULL ,
	[suser__sname] sysname NULL ,
	[db_nm] sysname NULL ,
	[nt__Username] sysname NULL ,
	[program__name] [nvarchar] (128) NULL ,
	[host_name] [nchar] (128) NULL ,
	[kp_id] [smallint] NULL ,
	[unmailed] [tinyint] NOT NULL CONSTRAINT [DF__login_not__unmai__08EA5793] DEFAULT (1),
	CONSTRAINT [pk_login_time_sp_id] PRIMARY KEY  CLUSTERED 
	(
		[login__time],
		[sp_id]
	)  
) 
END

GO
CREATE  INDEX [nc_unmailed] ON [dbo].[login_notify_perm]([unmailed]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO

use master
go
-- turn on system stored procedure registration
exec dbo.sp_configure 'allow updates',1
go
reconfigure with override
go
exec sp_MS_upd_sysobj_category 1
go

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp__login$sendNotify]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp__login$sendNotify]
GO

CREATE procedure sp__login$sendNotify
(	@suser_sname		varchar(255) = '%',
	@recipients		varchar(255) = '',
	@copy_recipients	varchar(255) = '',  	
	@sendMail		bit = 1
)  as
---------------------------------------------------------------------------------------------------------------
--	Description
-- 		Sends email result sets of most recent standard login passed from task which was called by
--		alert.  Records most recent non-logged login(s) into 90 day record.
--
--	Implementation Notes
--
--	Results Sets
--		Sends email notification
--
--	Returns
--		Enters standard login data into master..login_notify_perm table.  Primarily used for sa 
--		login tracking.  Could be used for any standard login tracking based on input parms.
--
--	Preconditions
--		Existence of master..login_notify_perm table
--	Postconditions
--
--	Modification Log
--  
--  	Name   		Date      	Ver	Modification
--  	--------------	--------------  --- 	----------------------------
--	charles hawkins	1/1/2003	1.0	created
---------------------------------------------------------------------------------------------------------------
	declare @retval int
	set nocount on 
	--Get the information into the perm table immediately before waiting for 5 seconds.
	--Don't include thread 0 processes, kpid = 0, or SQLExec processes.  Integrated logins, which we don't want,
	--have nt_username = hostname,  The only bug here is for a login where the nt_username is equal to machine name, i.e. MST3
	--Don't duplicate an ealier login__time.
	--Unmailed column in perm table automatically gets value of 1, indicating not mailed.
	--This will also attempt to get data on the second recurse through the proc after the five seconds to ensure that 
	--we didn't miss any logins in the 5 second wait.
	
	INSERT master..login_notify_perm 
		(login__time, sp_id, suser__sname, db_nm, nt__Username, program__name, host_name, kp_id) 
		SELECT login_time, spid,  suser_sname(sid), convert(char(15),db_name(dbid)), nt_username,
		program_name, hostname, kpid
		FROM sysprocesses
		WHERE suser_sname(sid) like @suser_sname 
			AND RTRIM(nt_username) != RTRIM(@@servername)  -- This keeps out Service logins
			AND nt_username != hostname  --This keeps out integrated logins
			AND program_name NOT LIKE '%SQLEXEC%' --This keeps out SQLExecutive logins
			AND login_time NOT IN (SELECT DISTINCT login__time FROM master..login_notify_perm 
				WHERE DATEDIFF(hh, login__time, getdate()) < 36 )  --This keeps out logins already recorded

	declare @subject varchar(255), @query varchar(255)

	select @query = 'exec sp__login$sendNotify @suser_sname = ''' + @suser_sname + 
			''', @recipients = ''' + @recipients + ''', @copy_recipients = ''' + 
			@copy_recipients + ''', @sendMail = 0 '

	select @subject = 'Users logged in with: ' + @suser_sname + ' mask on server ' + @@servername

	if @sendMail = 1   -- This is the first loop through.  The alert passes a sendmail flag of 1.
	 begin
		waitfor delay '00:00:05'
		--call the mail engine to send our mail.  No report will be generated if the mail
		--service is not started	
		execute @retval = master..xp_sendmail 
			  @recipients = @recipients
			, @copy_recipients = @copy_recipients
			, @query = @query
			, @subject = @subject	--since we have a wide message, we attacht the results as a text file
				--and set the width really large
			, @attach_results = 'false'
			, @width = 2000
	 end
	else
	--Sendmail is equal to 0.  This is the recurse through the proc that actually does the work to 
	--gather data for sending out and updating the permanent history table.
	 begin
		declare @lenSuser_sname tinyint, @lenDb_nm tinyint, @lenNt__username tinyint, 
			@lenProgram__name tinyint, @lenHost_name tinyint, @exec_cmd nvarchar(4000)
		select @lenSuser_sname = max(len(suser__sname)),
			@lenDb_nm = max(len(db_nm)),@lenNt__username = max(len(nt__username)),
			@lenProgram__name = max(len(program__name)),@lenHost_name = max(len([host_name]))
			from master..login_notify_perm WHERE 	unmailed = 1
		IF @lenHost_name IS NULL SELECT @lenHost_name = 10
		IF @lenSuser_sname IS NULL SELECT @lenSuser_sname = 7
		IF @lenDb_nm IS NULL SELECT @lenDb_nm = 10
		IF @lenNt__username IS NULL SELECT @lenNt__username = 10
		IF @lenProgram__name IS NULL SELECT @lenProgram__name = 10

			
		select	@subject
		union 	all
		select 	''
		--Get the data from the temp table.  Don't include any existing rows in the permanent table, i.e. unmailed = 0
		select @exec_cmd = 'SELECT 	substring([suser__sname],1,'+convert(varchar(3),@lenSuser_sname)+') as ''User Name'', 
			sp_id AS spid, substring([db_nm],1,'+convert(varchar(3),@lenDb_nm)+') as ''Database Name'', 
			substring([nt__username],1,'+convert(varchar(3),@lenNt__username)+') as ''NT ID'', 
			substring(ISNULL([program__name],''NONE''),1,'+convert(varchar(3),@lenProgram__name)+') as Application, 
			substring(ISNULL([host_name],''NONE''),1,'+convert(varchar(3),@lenHost_name)+') as ''host_name'', login__time as login_time			
			FROM	master..login_notify_perm
			WHERE 	unmailed = 1
			ORDER   by login__time desc'
		--select @exec_cmd
		exec (@exec_cmd)
		IF @@ROWCOUNT = 0
			BEGIN
				select 'This was a programmatic login.  See the SQL error log and NT event log for details'
			END
		
		--Update the mailed description to indicate that the data has been mailed and doesn't need to be sent again.
		UPDATE master..login_notify_perm SET unmailed = 0 where unmailed = 1

		--Take this opportunity to clean up any perm table entries older than 90 days.
		DELETE FROM master..login_notify_perm WHERE DATEDIFF(day, login__time, getdate()) >90 
 					
	 end
GO

-- turn off system stored procedure registration
exec dbo.sp_configure 'allow updates',0
go
reconfigure with override
go
exec sp_MS_upd_sysobj_category 2
go


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'SA login email notify')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''SA login email notify'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'SA login email notify' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'SA login email notify', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Step 1', @command = N'exec sp__login$sendNotify @suser_sname = ''sa'', @recipients = ''your-email@company.com'', @sendMail = 1', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 

GO

-- Alert script
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'SA non-trusted login'))
 ---- Delete the alert with the same name.
  EXECUTE msdb.dbo.sp_delete_alert @name = N'SA non-trusted login' 
BEGIN 
EXECUTE msdb.dbo.sp_add_alert @name = N'SA non-trusted login', @message_id = 18454, 
@severity = 0, @enabled = 1, @delay_between_responses = 8, @include_event_description_in = 5, 
@event_description_keyword = N'''sa''', @job_name = N'SA login email notify', 
@category_name = N'[Uncategorized]'

END



