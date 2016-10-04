-- NOTE: This job will put object history in the master database.
-- You may want to relocate the tables to another database.
-- ----------------------------------------------------------------------------
-- Important: The job is set up to send email to your_email@company.com. Change it to 
-- a suitable email address.
-- ----------------------------------------------------------------------------
-- This job will append an "Objects" folder to your SQL Server log folder
-- where your error logs are normally kept.
-- ----------------------------------------------------------------------------

/***** CREATE TABLE OBJECT_HIST ***********************************/
SET NOCOUNT ON
use master
go

if exists (select * from dbo.sysobjects where id = object_id(N'[object_hist]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [object_hist]
GO

-- The primary key is the DBID, time, Obj ID and ObjectType. There are times when both a table
-- and its primary key contraint are made at the same time. Both have the same object ID, just different
-- types.
CREATE TABLE [object_hist] (
	[StartTime] [datetime] NOT NULL ,
        [DatabaseID] [int] NOT NULL ,
        [ObjectID] [int] NOT NULL ,	
        [NTUserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NTDomainName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HostName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ApplicationName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SPID] [int] NULL ,
	[ServerName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EventClass] [int] NOT NULL ,
	[ObjectType] [int] NOT NULL ,
	[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LoginSid] [image] NULL ,
	[SysDatabase] [sysname] NULL ,
	[reported] [bit] NOT NULL CONSTRAINT [DF_object_hist_reported] DEFAULT (0),
	CONSTRAINT [PK_object_hist] PRIMARY KEY  CLUSTERED 
	(
		[DatabaseID],
		[StartTime],
		[ObjectID],
		[ObjectType]
	)  
) 
GO

/***** CREATE TABLE TRACEINFO  ***********************************/

use master
go

if exists (select * from dbo.sysobjects where id = object_id(N'[traceinfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [traceinfo]
GO

CREATE TABLE [traceinfo] (
	[ident] [int] IDENTITY (1, 1) NOT NULL ,
	[traceid] [int] NOT NULL ,
	[trace_filename] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[uploaded] [bit] NOT NULL CONSTRAINT [DF_traceinfo_uploaded] DEFAULT (0),
	[create_date] [datetime] NOT NULL CONSTRAINT [DF_traceinfo_create_date] DEFAULT (getdate()),
        CONSTRAINT [PK_traceinfo] PRIMARY KEY  CLUSTERED 
	(
		[ident]
	)   

) 
GO


-- Note: We are assuming that your SQL implementation is in C:\Program Files\Microsoft SQL Server'
INSERT master.dbo.traceinfo (traceid, trace_filename)
values(999,N'C:\Program Files\Microsoft SQL Server\Mssql\Log\Objects\initialdummy')

/********* CREATE FOLDER OBJECTS UNDER C:\MSSQL\LOG FOLDER *********/
DECLARE @data varchar(1000), @rc int, @cmd varchar(1000)
EXECUTE @rc = master.dbo.xp_instance_regread 
        N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Parameters', N'SQLArg1',
        @data OUTPUT, N'no_output'
select @data=reverse(substring(reverse(substring(@data,3,998)),9,988))
SELECT @cmd = 'mkdir "'+@data+'Objects"'
exec master..xp_cmdshell @cmd,NO_OUTPUT
CREATE TABLE #fileexist 
(FileExists bit, FileIsDirectory bit, ParentDirectoryExists bit)
SELECT @cmd = @data+'Objects'
INSERT #fileexist 
EXECUTE master.dbo.xp_fileexist @cmd
IF NOT EXISTS (SELECT 1 FROM #fileexist where FileIsDirectory = 1)
   PRINT 'WARNING: Folder "'+@data+'Objects" doesn''t exist. Please create it.'
ELSE
  BEGIN
	PRINT ''
   	PRINT 'Folder "'+@data+'Objects" exists. It is the temporary home of object traces.'
	PRINT ''
  END
DROP TABLE #fileexist

-- Make the procedure a system stored procedure
exec dbo.sp_configure 'allow updates',1
go
reconfigure with override
go
exec sp_MS_upd_sysobj_category 1
go

/********* CREATE PROC sp__objectHistory$setupTraceRecordHistory *****/
use master
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp__objectHistory$setupTraceRecordHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp__objectHistory$setupTraceRecordHistory]
GO

create procedure sp__objectHistory$setupTraceRecordHistory
AS

set nocount on

---------------------------------------------------------------------------------------------------------------
--	Description
--	This procedure sets up a trace history file in the Log directory of your SQL Server.	
--
--	Implementation Notes
--	This procedure uses UNDOCUMENTED functionality. xp_instance_regread; xp_fileexist
--	Results Sets
--		
--
--	Returns
--	No returns since it is startup procedure.	
--
--	Preconditions
--	
--	Postconditions
--
--	Modification Log
--  
--  	Name     	Date      	Ver	Modification
--  	--------------  --------------  ----	----------------------------
--	charles hawkins	11/11/2002	1.0	Original

---------------------------------------------------------------------------------------------------------------

-- This is only good for SQL 2000
IF @@version not like '%8.00%' return 0

-- declare variables
declare @traceid int,@maxfilesize bigint, @rc int, @cmd varchar(8000),
	@on bit, @off bit, @filename nvarchar(255), @ident int, @error int
declare @intvalue int 
create table #fileexists (fileExists int,fileIsADirectory int,parentDirectoryExists int)

-- find the latest traceid
select  top 1 @traceid = traceid, @filename = trace_filename, @ident = ident 
from master.dbo.traceinfo
where uploaded = 0
order by ident desc

/*********************** UNDOCUMENTED use of xp_fileexist *********************/
IF @filename IS NOT NULL
	insert #fileExists EXEC @rc = [master].[dbo].[xp_fileexist] @filename


-- see if the traceID is still active
IF EXISTS(SELECT * FROM :: fn_trace_getinfo(@traceid))
  begin
	-- stop the trace
	exec master.dbo.sp_trace_setstatus @traceid =  @traceid ,  @status = 0
	
	-- destroy the trace
	exec master.dbo.sp_trace_setstatus @traceid =  @traceid 
	    ,  @status = 2
  end

-- results need to be uploaded if file exists
if (select fileExists from #fileExists) = 1
  begin  -- 1
	begin tran
	-- load the trace file up into the table
	INSERT INTO [master].[dbo].[object_hist]([DatabaseID], [NTUserName], [NTDomainName], [HostName], [ApplicationName], [LoginName], [SPID], [StartTime], [ObjectID], [ServerName], [EventClass], [ObjectType], [ObjectName], [DatabaseName], [LoginSid])
	SELECT t.DatabaseID,t.NTUserName,t.NTDomainName,t.HostName,
	t.ApplicationName,t.LoginName,t.SPID,t.StartTime, t.ObjectID,t.ServerName,
	t.EventClass,t.ObjectType,
	case 
	when substring(t.objectName,1,3) = 'dbo' then 'dbo.'+substring(t.objectname,5,len(t.objectname)-4)
	else t.objectname end,
	ISNULL(d.[Name],'Deleted'),t.LoginSid 
	FROM ::fn_trace_gettable(@filename, -1) t
	LEFT OUTER JOIN master.dbo.sysdatabases d on t.databaseID = d.dbid

	SELECT @error = @@error
	IF @error <> 0
	  begin -- 2
		raiserror ('Error in load of file into object_hist table',16,-1)
		rollback tran
	  end  -- 2
	ELSE
	  BEGIN  -- 2
		update master.dbo.traceinfo set uploaded = 1 where ident = @ident
		SELECT @error = @@error
		IF @error <> 0
		  begin -- 3
			raiserror ('Error in update of traceinfo table',16,-1)
			rollback tran
		  end -- 3
		ELSE
		-- commit the tran, delete the file call @filename
		  begin -- 3
			commit tran
			select @cmd = 'del ' + convert(varchar(255),@filename) 
			exec master.dbo.xp_cmdshell @cmd, NO_OUTPUT
		  end -- 3
	  END -- 2

  end -- 1

drop table #fileExists

-- build the filename
-- Get the log file path from the registry for the instance
/*********************** UNDOCUMENTED use of xp_instance_regread *********************/
DECLARE @data varchar(1000)
EXECUTE @rc = master.dbo.xp_instance_regread 
        N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Parameters', N'SQLArg1',
        @data OUTPUT, N'no_output'
select @data=reverse(substring(reverse(substring(@data,3,998)),9,988))

select @filename = CONVERT(NVARCHAR(1000),@data)+N'objects_created_'
+ convert(nvarchar(10),GETDATE(),112)
+ N'_' + RIGHT(N'0'+ convert(nvarchar(2),datepart(hh,GETDATE())),2)
+ RIGHT(N'0'+ convert(nvarchar(2),datepart(mi,GETDATE())),2)
+ RIGHT(N'0'+ convert(nvarchar(2),datepart(ss,GETDATE())),2)

select @maxfilesize = 5, @on = 1, @off = 0

-- create the trace
exec @rc = master.dbo.sp_trace_create  @traceid =  @traceid OUTPUT 
    ,  @options = 2
   ,  @tracefile =  @filename
    ,  @maxfilesize =  @maxfilesize 
--     ,  @stoptime =  'stop_time' 

-- Test info
-- select @rc AS 'Return Code', @traceid As 'Trace ID', @filename AS 'File'

-- set up the create event
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid =  46,  @columnid =  34
	,  @on =  @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid =  46,  @columnid =  35
	,  @on =  @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  3
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  6
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  7
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  8
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 10
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 11
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 12
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 13
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 14
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 15
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 16
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 17
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid = 18
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  20
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  21
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  22
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  24
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  26
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  27
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  28
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  37
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 46,@columnid =  41
    ,  @on = @on


-- set up the delete event
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  34
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid =  47,  @columnid =  35
	,  @on =  @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  3
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  6
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  7
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  8
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 10
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 11
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 12
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 13
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 14
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 15
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 16
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 17
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid = 18
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  20
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  21
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  22
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  24
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  26
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  27
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
   ,  @eventid = 47,@columnid =  28
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  37
    ,  @on = @on
exec master.dbo.sp_trace_setevent  @traceid =  @traceid 
    ,  @eventid = 47,@columnid =  41
    ,  @on = @on

select @intvalue = 2
-- Set a filter to not look at tempdb, dbid = 2, columnid for dbid = 3
exec master.dbo.sp_trace_setfilter  @traceid =  @traceid 
    ,  @columnid =  3
    ,  @logical_operator =  0
    ,  @comparison_operator =  1
    ,  @value =  @intvalue

--SELECT * FROM :: fn_trace_getinfo(1)

-- start the trace
exec master.dbo.sp_trace_setstatus @traceid =  @traceid 
    ,  @status = 1

-- Old test info
--WAITFOR DELAY '00:00:30'
-- SELECT * FROM :: fn_trace_getinfo(@traceid)
-- exec master.dbo.sp_trace_setstatus @traceid =  1 ,  @status = 2

select @filename = @filename + N'.trc'

insert master.dbo.traceinfo (traceid,trace_filename)
values (@traceid, @filename)

GO

exec sp_MS_upd_sysobj_category 2
go
exec sp_configure 'allow updates',0
go
reconfigure with override
go

exec sp_procoption N'sp__objectHistory$setupTraceRecordHistory', N'startup', N'true'
GO

/**********CREATE PROC sp__objecthistory$notifyOfChange ********/
use master
go
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp__objecthistory$notifyOfChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp__objecthistory$notifyOfChange]
GO


Create procedure dbo.sp__objecthistory$notifyOfChange
(
	@sendmail	bit	 = 0, 		--if this = 1 a message will be emailed to 
						--the recipients listed in the next parm
	@recipients	varchar(255) = ' ' 	--fill this parm with a semicolon delimeted
						--list of email names
)  as

---------------------------------------------------------------------------------------------------------------
--	Description
--		Emails data for objects in Object_Hist table where reported = 0
--
--	Implementation Notes
--
--	Results Sets
--		(8) Not documented.
--
--	Returns
--		1 indicates error with xp_sendmail
--		0 if successful, -1 to -99 for system errors
--		-100 for invalid datatype passed in
--
--	Preconditions
--
--	Postconditions
--
--	Modification Log
--  
--  	Name     	Date      	Ver	Modification
--  	--------------  --------------  ----	----------------------------
--	charles hawkins	11/11/2002	1.0	Original
---------------------------------------------------------------------------------------------------------------
-- jane, stop that crazy rowcount message! (Shades of Louis Davidson)
set nocount on

DECLARE @LastTime datetime

--don't want to return anything or create mail if no changes have been made
-- Test first to see if there are any new rows indicating changes.
if (	select 	count(*)
	from 	object_hist
	where 	reported = 0
	and objectName NOT LIKE '[_]WA[_]%') = 0  -- these are SQL generated indexes
   return 0

-- If we get to this point, it means we will generate some type of email.

-- Reset @LastTime to be one hour before the most recent upd_dt
SELECT @LastTime = dateadd(hh,-1,@LastTime)

--for sending mail.  We call this function recursively with sendmail = 0.  A
--kind of tricky way to do it, but it makes the public interface of this proc
--easier to understand
if @sendmail = 1
 begin
	declare @retval int, @message varchar(255), @subject varchar(255)
	--create the header for the message.
	select 	@message = 'The following message is autogenerated by SQL Server ' + @@servername

	--we are allowing this parm to be overridden
	if @subject is null
		select 	@subject = 'new object creations and/or deletions records on '+rtrim(ltrim(@@servername))+' as of ' + convert(varchar(30), getdate(), 113)
	
	declare @query varchar(255)
	select	@query = 'execute master.dbo.sp__objecthistory$notifyOfChange @sendmail = 0, @recipients = ''' +  @recipients + ''''

	--call the mail engine to send our mail.  No report will be generated if the mail
	--service is not started
	execute @retval = master..xp_sendmail 
		  @recipients = @recipients
		, @message = @message
			--note that we are telling the call not to send mail this time.  If you
			--don't do this, you will recurse yourself to death
		, @query = @query
		, @subject = @subject
			--since we have a wide message, we attacht the results as a text file
			--and set the width really large
		, @attach_results = 'true'
		, @width = 2000
		, @no_output = 'true'

 	return @retval
 end


--the following are the output queries
select 	'History of object events are in chronological order (first to last)'

declare @db_nm sysname, @owner_nm sysname, @table_nm sysname, @setng_nbr int
--same query as above.  that gets all current new items
declare @lenNTUserName int, @lenNTDomainName int, @lenHostname int, @lenApplicationName int, 
@lenLoginName int, @lenServerName int, @lenObjectName int, @lenDatabaseName int, 
@cmd varchar(4000), @cmd1 varchar(4000)

-- Get the max db_nm, max table_nm, and max setng_nm lengths to format the output
select @lenNTUserName = max(len(ISNULL(NTUserName,''))),
	@lenNTDomainName = max(len(ISNULL(NTDomainName,''))),
	@lenHostname = max(len(ISNULL(Hostname,''))),
	@lenApplicationName = max(len(ISNULL(ApplicationName,''))),
	@lenLoginName = max(len(ISNULL(LoginName,''))),
	@lenServerName = max(len(ISNULL(ServerName,''))),
	@lenObjectName = max(len(ISNULL(ObjectName,''))),
	@lenDatabaseName = max(len(ISNULL(DatabaseName,'')))
	from 	object_hist where reported = 0

-- We build this command so we have a nicely formatted message in our email
select @cmd = 'select CASE WHEN EventClass = 46 THEN ''Created'' ELSE ''Deleted'' END AS ''EventClass'',
''ObjectName'' = substring(ObjectName,1,'+convert(varchar(10),@lenObjectName)+'), 
''DatabaseName'' = substring(DatabaseName,1,'+convert(varchar(10),@lenDatabaseName)+'), 
StartTime, 
''NTUserName'' = substring(NTUserName,1,'+convert(varchar(10),@lenNTUserName)+'), 
''NTDomainName'' = substring(NTDomainName,1,'+convert(varchar(10),@lenNTDomainName)+'), 
''Hostname'' = substring(Hostname,1,'+convert(varchar(10),@lenHostname)+'), 
''ApplicationName'' = substring(ApplicationName,1,'+convert(varchar(10),@lenApplicationName)+'), 
SPID, ObjectID, 
''LoginName'' = substring(LoginName,1,'+convert(varchar(10),@lenLoginName)+'), 
''ServerName'' = substring(ServerName,1,'+convert(varchar(10),@lenServerName)+'), 
EventClass, ObjectType
from 	master.dbo.object_hist where reported = 0 and objectName NOT LIKE ''[_]WA[_]%''
order by StartTime '	
--select @cmd	 
exec (@cmd)
IF @@error = 0
	UPDATE master.dbo.object_hist set reported = 1 where reported = 0

GO

-- Turn off making system stored procedures
exec sp_MS_upd_sysobj_category 2
go
exec sp_configure 'allow updates',0
go
reconfigure with override
go

/******************** JOB SCHEDULING SCRIPT ************************/

BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'WatchDog') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'WatchDog'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'Watchdog: Object Capture')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''Watchdog: Object Capture'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'Watchdog: Object Capture' 
    SELECT @JobID = NULL
  END 

-- In our settings, some servers have SMTP_SENDMAIL, others user regular SENDMAIL.
IF NOT EXISTS (SELECT 1 FROM MASTER.DBO.SYSOBJECTS WHERE NAME = 'XP_SMTP_SENDMAIL')
   BEGIN 
	
	  -- Add the job
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'Watchdog: Object Capture', @owner_login_name = N'sa', @description = N'Capture objects to C:\MSSQL\LOGS\OBJECTS folder and then writes them into master', @category_name = N'WatchDog', @enabled = 1, @notify_level_email = 2, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 3, @delete_level= 0, @notify_email_operator_name = N'DataAdministration-Compass@compass.net'
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
	  -- Add the job steps
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Object Capture Recycle', @command = N'exec master.dbo.sp__objectHistory$setupTraceRecordHistory
	EXEC [master].[dbo].[sp__objecthistory$notifyOfChange] 1, ''your_email@company.com''
	', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 
	
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
	  -- Add the job schedules
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Every hour starting at midnight', @enabled = 1, @freq_type = 4, @active_start_date = 20021111, @active_start_time = 0, @freq_interval = 1, @freq_subday_type = 8, @freq_subday_interval = 1, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
	  -- Add the Target Servers
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
   END
ELSE -- using SMTP Sendmail
   BEGIN 
	
	  -- Add the job
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'Watchdog: Object Capture', @owner_login_name = N'sa', @description = N'Capture objects to \MSSQL\LOGS\OBJECTS folder and then writes them into master', @category_name = N'Watchdog', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 3, @delete_level= 0
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
	  -- Add the job steps
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Object Capture Recycle', @command = N'exec master.dbo.sp__objectHistory$setupTraceRecordHistory
	EXEC [master].[dbo].[sp__objecthistory$notifyOfChange] 1, ''your_email@company.com''
	', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 2, @on_fail_action = 4
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure', @command = N'declare @rc int
	exec @rc = master.dbo.xp_smtp_sendmail @FROM = @@servername,
	@TO = N''your_email@company.com'',
	@SUBJECT = N''Failure on job [Watchdog: Object Capture]'',
	@type = N''text/plain''
	select RC = @rc 
	', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 
	
	  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
	
	  -- Add the job schedules
	  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Every hour starting at midnight', @enabled = 1, @freq_type = 4, @active_start_date = 20021111, @active_start_time = 0, @freq_interval = 1, @freq_subday_type = 8, @freq_subday_interval = 1, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
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

PRINT 'A warning of a non-existent step reference is normal. Ignore it.'

-- Finally start the job to kick off a trace
EXEC MSDB.DBO.SP_START_JOB @JOB_NAME = 'Watchdog: Object Capture'

