SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE sp__errorlog$archivelog 
-- -----------------------------------------
-- sp__errorlog$archivelog
-- -----------------------------------------
-- WARNING: This procedure uses UNDOCUMENTED functionality compatible -- with SQL Server 2000 GA, Service Pack 1, and Service Pack 2.
-- ----------------------------------------
-- Description:
-- Create an ISO log from the "errorlog.1" file each time errorlog is
-- cycled or server restarts. An ISO log is a 'date-named' file named -- like: errorlog.yyyymmdd

-- This proc is run at each sql server startup (which creates a new 
-- errorlog.1 file).

-- It is also run by a SqlAgent task that runs at midnight, and right -- before it calls this proc, it issues "dbcc errorlog" to cause a new -- "errorlog.1" to be built.

-- If this proc is run accidently before a new "errorlog.1" is
-- created, it will just append the current errorlog.1 to the ISO 
-- log file again. No harm is done as it's just duplicate data.

--  Run this job from SQL Agent at 23:59 every night.

-- Implementation
-- IMPORTANT:  Each time you re-create this procedure, it needs to be -- made a startup procedure. Run the command: 
-- exec sp_procoption N'sp__errorlog$archivelog', N'startup', N'true'
-- -------------------------------------------

AS
DECLARE @PathNoExt NVARCHAR(1000), -- path to error log from the
                                   --registry
@PathISO VARCHAR(255),    --the ISO format log, errorlog.YYYYMMDD
@DosCmd VARCHAR(255),     --Dos command to append errorlog.1 to make 
                          --date-name errorlog
@RC INT                   --The return code
--  ----------------------------------------
-- Only cycle the errorlog between 23:59 and 24:00, otherwise just
-- append current errorlog.1 to an existing file
-- ----------------------------------------

WAITFOR DELAY '000:00:02'    -- wait for two seconds to ensure we are
                            -- well into the 23:59 minute.

IF GETDATE() BETWEEN DATEADD(N,-1, DATEADD(D,1,CONVERT(DATETIME,
  CONVERT(VARCHAR(20),GETDATE(),101)))) AND
  DATEADD(D,1,CONVERT(DATETIME,CONVERT(VARCHAR(20),GETDATE(),101)))
BEGIN
  EXEC @RC = master.dbo.sp_cycle_errorlog

  IF @RC <> 0
  BEGIN
    RAISERROR 50000 'Errorlog did not cycle'
    RETURN -1
  END
END

-- ----------------------------------------
-- Get the Path to the Sql ErrorLog from the registry
-- ----------------------------------------
Exec @Rc = master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
           N'Software\Microsoft\MSSQLServer\ MSSQLServer\Parameters',
           N'SQLArg1', @PathNoExt OUTPUT, N'no_output'

IF (@PathNoExt is null) or @RC <> 0
BEGIN
  RAISERROR 50000 'sp_errorlog$archiveLog cannot obtain Sql ErrorLog
    Path'
  RETURN -2
END

-- -----------------------------------------
-- Create Output FileName based on date (ISO name)
-- ----------------------------------------
-- Trim off the first two characters and append a backslash and the --- file name
SELECT @PathISO = SUBSTRING(@PathNoExt,3,998)+ N'\errorlog.' + 
  CONVERT(CHAR(8), GETDATE(), 112)
SELECT @PathNoExt = SUBSTRING(@PathNoExt,3,998) + N'\errorlog.1'

-- ---------------------------------------
-- Build commands to append new errorlog.1 to the Date-Name (ISO) 
-- file. @DosCmd will look like:
-- TYPE "C:\MSSQL\LOG\errorlog.1" >>"C:\MSSQL\LOG\errorlog.20010605"
-- The >> will create the output file if it does not exist. if it 
-- exists it will append it to the output file 
-- Use double-quotes around file names in case they have embedded 
-- spaces.
--  ----------------------------------------
SELECT @DosCmd = 'TYPE "' + @PathNoExt + '" >>"' + @PathISO + '"'

--  ----------------------------------------
-- Run TYPE command to append new errorlog.1 to the Date-Name (ISO) 
-- file.
--  ----------------------------------------
EXEC('xp_cmdshell ''' + @DosCmd + ''',no_output')
GO

-- Make the procedure a startup procedure
EXEC sp_procoption N'sp__errorlog$archivelog', N'startup', N'true'
GO
