CREATE PROCEDURE dbo.AuditAccess

AS

	SET NOCOUNT ON

	-- Create a Queue
	DECLARE 	@rc INT,

			@TraceID INT,

			@maxfilesize BIGINT

SET @maxfilesize = 5 

EXEC @rc = sp_trace_create @TraceID output, 0, N'C:\AuditTrace.trc', @maxfilesize, NULL 

IF (@rc != 0) GOTO error

DECLARE @on bit

SET @on = 1

EXEC sp_trace_SETevent @TraceID, 14, 1, @on
EXEC sp_trace_SETevent @TraceID, 14, 6, @on
EXEC sp_trace_SETevent @TraceID, 14, 9, @on
EXEC sp_trace_SETevent @TraceID, 14, 10, @on
EXEC sp_trace_SETevent @TraceID, 14, 11, @on
EXEC sp_trace_SETevent @TraceID, 14, 12, @on
EXEC sp_trace_SETevent @TraceID, 14, 13, @on
EXEC sp_trace_SETevent @TraceID, 14, 14, @on
EXEC sp_trace_SETevent @TraceID, 14, 16, @on
EXEC sp_trace_SETevent @TraceID, 14, 17, @on
EXEC sp_trace_SETevent @TraceID, 14, 18, @on
EXEC sp_trace_SETevent @TraceID, 15, 1, @on
EXEC sp_trace_SETevent @TraceID, 15, 6, @on
EXEC sp_trace_SETevent @TraceID, 15, 9, @on
EXEC sp_trace_SETevent @TraceID, 15, 10, @on
EXEC sp_trace_SETevent @TraceID, 15, 11, @on
EXEC sp_trace_SETevent @TraceID, 15, 12, @on
EXEC sp_trace_SETevent @TraceID, 15, 13, @on
EXEC sp_trace_SETevent @TraceID, 15, 14, @on
EXEC sp_trace_SETevent @TraceID, 15, 16, @on
EXEC sp_trace_SETevent @TraceID, 15, 17, @on
EXEC sp_trace_SETevent @TraceID, 15, 18, @on


DECLARE @intfilter INT,
	@BIGINTfilter BIGINT

EXEC sp_trace_SETfilter @TraceID, 10, 0, 7, N'SQL Profiler'

EXEC sp_trace_SETstatus @TraceID, 1

GOTO finish

error: 
SELECT ErrorCode=@rc

finish: 
