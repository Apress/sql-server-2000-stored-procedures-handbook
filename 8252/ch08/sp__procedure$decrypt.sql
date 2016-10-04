SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

drop procedure sp__procedure$decrypt
go

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE sp__procedure$decrypt  --atestobj, --@revfl = 0
(@procedure sysname = NULL, @revfl int = 1)
-- ---------------------------------------------------------------------------
-- CAUTION: THIS PROCEDURE DELETES AND REBUILDS THE ORIGINAL STORED PROCEDURE.
-- 	    MAKE A BACKUP OF YOUR DATABASE BEFORE RUNNING THIS PROCEDURE.
--	    IDEALLY, THIS PROCEDURE SHOULD BE RUN ON A NON-PRODUCTION COPY OF THE PROCEDURE.
-- ---------------------------------------------------------------------------
AS
SET NOCOUNT ON

IF @revfl = 1
   BEGIN
	PRINT 'CAUTION: THIS PROCEDURE DELETES AND REBUILDS THE ORIGINAL STORED PROCEDURE.'
	PRINT '	    MAKE A BACKUP OF YOUR DATABASE BEFORE RUNNING THIS PROCEDURE.'
	PRINT '	    IDEALLY, THIS PROCEDURE SHOULD BE RUN ON A NON-PRODUCTION COPY OF THE PROCEDURE.'
	PRINT ' To run the procedure, change the @revfl parameter to 0'
	RETURN 0
   END

DECLARE @intProcSpace bigint, @t bigint, @maxColID smallint,@intEncrypted tinyint,@procNameLength int
select @maxColID = max(colid),@intEncrypted = encrypted FROM syscomments WHERE id = object_id(@procedure) 
GROUP BY encrypted
IF @maxColID > 10
    BEGIN
	PRINT 'This procedure only works where the procedure is less than 40,000 characters long'
   	RETURN 1
    END
IF @intEncrypted = 0
    BEGIN
	SELECT 'Procedure '+@procedure+' is not encrypted.'
	RETURN 1
    END
--select @maxColID as 'Rows in SYSCOMMENTS'
select @procNameLength = datalength(@procedure) + 29

DECLARE @real_01 nvarchar(4000), @real_02 nvarchar(4000),@real_03 nvarchar(4000),
@real_04 nvarchar(4000),@real_05 nvarchar(4000),@real_06 nvarchar(4000),@real_07 nvarchar(4000),
@real_08 nvarchar(4000),@real_09 nvarchar(4000),@real_10 nvarchar(4000)
select @real_02 = '',@real_03 = '',@real_04 = '',@real_05 = '',
@real_06 = '',@real_07 = '',@real_08 = '',@real_09 = '',@real_10 = ''

DECLARE @fake_01 nvarchar(4000),@fake_02 nvarchar(4000),@fake_03 nvarchar(4000),
@fake_04 nvarchar(4000),@fake_05 nvarchar(4000),@fake_06 nvarchar(4000),@fake_07 nvarchar(4000),
@fake_08 nvarchar(4000),@fake_09 nvarchar(4000),@fake_10 nvarchar(4000)
select @fake_02 = '',@fake_03 = '',@fake_04 = '',@fake_05 = '',
@fake_06 = '',@fake_07 = '',@fake_08 = '',@fake_09 = '',@fake_10 = ''
 
DECLARE @fake_encrypt_01 nvarchar(4000),@fake_encrypt_02 nvarchar(4000),@fake_encrypt_03 nvarchar(4000),
@fake_encrypt_04 nvarchar(4000),@fake_encrypt_05 nvarchar(4000),@fake_encrypt_06 nvarchar(4000),@fake_encrypt_07 nvarchar(4000),
@fake_encrypt_08 nvarchar(4000),@fake_encrypt_09 nvarchar(4000),@fake_encrypt_10 nvarchar(4000)
select @fake_encrypt_02 = '',@fake_encrypt_03 = '',@fake_encrypt_04 = '',@fake_encrypt_05 = '',
@fake_encrypt_06 = '',@fake_encrypt_07 = '',@fake_encrypt_08 = '',@fake_encrypt_09 = '',@fake_encrypt_10 = ''

DECLARE @real_decrypt_01 nvarchar(4000),@real_decrypt_02 nvarchar(4000),@real_decrypt_03 nvarchar(4000),
@real_decrypt_04 nvarchar(4000),@real_decrypt_05 nvarchar(4000),@real_decrypt_06 nvarchar(4000),@real_decrypt_07 nvarchar(4000),
@real_decrypt_08 nvarchar(4000),@real_decrypt_09 nvarchar(4000),@real_decrypt_10 nvarchar(4000)

-- extract the encrypted ctext rows from syscomments
SET @real_01=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 1)
IF @maxColID > 1 SET @real_02=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 2)
IF @maxColID > 2 SET @real_03=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 3)
IF @maxColID > 3 SET @real_04=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 4)
IF @maxColID > 4 SET @real_05=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 5)
IF @maxColID > 5 SET @real_06=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 6)
IF @maxColID > 6 SET @real_07=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 7)
IF @maxColID > 7 SET @real_08=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 8)
IF @maxColID > 8 SET @real_09=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 9)
IF @maxColID > 9 SET @real_10=(select ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 10)

-- alter the original procedure, replacing with dashes
SET @fake_01='ALTER PROCEDURE '+ @procedure +' WITH ENCRYPTION AS '+REPLICATE('-',  4001 - @procNameLength)
IF @maxColID > 1 SET @fake_02=REPLICATE('-', 4000)
IF @maxColID > 2 SET @fake_03=REPLICATE('-', 4000)
IF @maxColID > 3 SET @fake_04=REPLICATE('-', 4000)
IF @maxColID > 4 SET @fake_05=REPLICATE('-', 4000)
IF @maxColID > 5 SET @fake_06=REPLICATE('-', 4000)
IF @maxColID > 6 SET @fake_07=REPLICATE('-', 4000)
IF @maxColID > 7 SET @fake_08=REPLICATE('-', 4000)
IF @maxColID > 8 SET @fake_09=REPLICATE('-', 4000)
IF @maxColID > 9 SET @fake_10=REPLICATE('-', 4000)
EXECUTE (@fake_01 + @fake_02 + @fake_03 + @fake_04 + @fake_05
+ @fake_06 + @fake_07 + @fake_08 + @fake_09 + @fake_10)

-- extract the encrypted fake ctext rows from syscomments
SET @fake_encrypt_01=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 1)
IF @maxColID > 1 SET @fake_encrypt_02=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 2)
IF @maxColID > 2 SET @fake_encrypt_03=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 3)
IF @maxColID > 3 SET @fake_encrypt_04=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 4)
IF @maxColID > 4 SET @fake_encrypt_05=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 5)
IF @maxColID > 5 SET @fake_encrypt_06=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 6)
IF @maxColID > 6 SET @fake_encrypt_07=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 7)
IF @maxColID > 7 SET @fake_encrypt_08=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 8)
IF @maxColID > 8 SET @fake_encrypt_09=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 9)
IF @maxColID > 9 SET @fake_encrypt_10=(SELECT ctext FROM syscomments WHERE id = object_id(@procedure) and colid = 10)

SET @fake_01='CREATE PROCEDURE '+ @procedure +' WITH ENCRYPTION AS '+REPLICATE('-', 4000 - @procNameLength)
--start counter
SET @intProcSpace=1
--fill temporary variable with with a filler character
SET @real_decrypt_01 = replicate(N'A', (datalength(@real_01)  /2    ))
IF @maxColID > 1 SET @real_decrypt_02 = replicate(N'A', (datalength(@real_02)  /2    ))
IF @maxColID > 2 SET @real_decrypt_03 = replicate(N'A', (datalength(@real_03)  /2    ))
IF @maxColID > 3 SET @real_decrypt_04 = replicate(N'A', (datalength(@real_04)  /2    ))
IF @maxColID > 4 SET @real_decrypt_05 = replicate(N'A', (datalength(@real_05)  /2    ))
IF @maxColID > 5 SET @real_decrypt_06 = replicate(N'A', (datalength(@real_06)  /2    ))
IF @maxColID > 6 SET @real_decrypt_07 = replicate(N'A', (datalength(@real_07)  /2    ))
IF @maxColID > 7 SET @real_decrypt_08 = replicate(N'A', (datalength(@real_08)  /2    ))
IF @maxColID > 8 SET @real_decrypt_09 = replicate(N'A', (datalength(@real_09)  /2    ))
IF @maxColID > 9 SET @real_decrypt_10 = replicate(N'A', (datalength(@real_10)  /2    ))

--loop through each of the variables sets of variables, building the real variable
--one byte at a time.
SET @intProcSpace=1

-- Go through each @real_xx variable and decrypt it, as necessary
WHILE @intProcSpace<=(datalength(@real_01)/2)
	BEGIN
		--xor real & fake & fake encrypted
		SET @real_decrypt_01 = stuff(@real_decrypt_01, @intProcSpace, 1,
		 NCHAR(UNICODE(substring(@real_01, @intProcSpace, 1)) ^
		 (UNICODE(substring(@fake_01, @intProcSpace, 1)) ^
		 UNICODE(substring(@fake_encrypt_01, @intProcSpace, 1)))))
		SET @intProcSpace=@intProcSpace+1
		--IF @intProcSpace = 3950 select @real_decrypt_01
	END

IF @maxColID > 1  
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_02)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_02 = stuff(@real_decrypt_02, @intProcSpace, 1,
			 CHAR(UNICODE(substring(@real_02, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_02, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_02, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END

IF @maxColID > 2 
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_03)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_03 = stuff(@real_decrypt_03, @intProcSpace, 1,
			 CHAR(UNICODE(substring(@real_03, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_03, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_03, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END

IF @maxColID > 3
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_04)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_04 = stuff(@real_decrypt_04, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_04, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_04, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_04, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 4
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_05)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_05 = stuff(@real_decrypt_05, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_05, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_05, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_05, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 5
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_06)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_06 = stuff(@real_decrypt_06, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_06, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_06, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_06, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 6
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_07)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_07 = stuff(@real_decrypt_07, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_07, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_07, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_07, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 7
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_08)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_08 = stuff(@real_decrypt_08, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_08, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_08, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_08, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 8
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_09)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_09 = stuff(@real_decrypt_09, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_09, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_09, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_09, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


IF @maxColID > 9
   BEGIN
	SET @intProcSpace=1
	WHILE @intProcSpace<=datalength(@real_10)/2
		BEGIN
			--xor real & fake & fake encrypted
			SET @real_decrypt_10 = stuff(@real_decrypt_10, @intProcSpace, 1,
			 NCHAR(UNICODE(substring(@real_10, @intProcSpace, 1)) ^
			 (UNICODE(substring(@fake_10, @intProcSpace, 1)) ^
			 UNICODE(substring(@fake_encrypt_10, @intProcSpace, 1)))))
			SET @intProcSpace=@intProcSpace+1
		END
    END


-- Load the variables into #output for handling by sp_helptext logic
create table #output (	[ident] [int] IDENTITY (1, 1) NOT NULL ,
	[real_decrypt] NVARCHAR(4000) )
	
insert #output (real_decrypt)
select @real_decrypt_01

IF @maxColID > 1 insert #output (real_decrypt) select @real_decrypt_02 
IF @maxColID > 2 insert #output (real_decrypt) select @real_decrypt_03 
IF @maxColID > 3 insert #output (real_decrypt) select @real_decrypt_04
IF @maxColID > 4 insert #output (real_decrypt) select @real_decrypt_05 
IF @maxColID > 5 insert #output (real_decrypt) select @real_decrypt_06 
IF @maxColID > 6 insert #output (real_decrypt) select @real_decrypt_07 
IF @maxColID > 7 insert #output (real_decrypt) select @real_decrypt_08 
IF @maxColID > 8 insert #output (real_decrypt) select @real_decrypt_09 
IF @maxColID > 9 insert #output (real_decrypt) select @real_decrypt_10

--select * from #output order by ident

-- -------------------------------------
-- Beginning of extract from sp_helptext
-- -------------------------------------
declare @dbname sysname
,@BlankSpaceAdded   int
,@BasePos       int
,@CurrentPos    int
,@TextLength    int
,@LineId        int
,@AddOnLen      int
,@LFCR          int --lengths of line feed carriage return
,@DefinedLength int

-- NOTE: Length of @SyscomText is 4000 to replace the length of
-- text column in syscomments.
-- lengths on @Line, #CommentText Text column and
-- value for @DefinedLength are all 255. These need to all have
-- the same values. 255 was selected in order for the max length
-- display using down level clients

,@SyscomText	nvarchar(4000)
,@Line          nvarchar(255)


Select @DefinedLength = 255
SELECT @BlankSpaceAdded = 0 --Keeps track of blank spaces at end of lines. Note Len function ignores trailing blank spaces
CREATE TABLE #CommentText
(LineId	int
 ,Text  nvarchar(255) collate database_default)


-- use #output instead of syscomments
DECLARE ms_crs_syscom  CURSOR LOCAL
FOR SELECT real_decrypt from #output 
        ORDER BY ident
FOR READ ONLY


--  Else get the text.

SELECT @LFCR = 2
SELECT @LineId = 1


OPEN ms_crs_syscom

FETCH NEXT FROM ms_crs_syscom into @SyscomText

WHILE @@fetch_status >= 0
BEGIN

    SELECT  @BasePos    = 1
    SELECT  @CurrentPos = 1
    SELECT  @TextLength = LEN(@SyscomText)

    WHILE @CurrentPos  != 0
    BEGIN
        --Looking for end of line followed by carriage return
        SELECT @CurrentPos =   CHARINDEX(char(13)+char(10), @SyscomText, @BasePos)

        --If carriage return found
        IF @CurrentPos != 0
        BEGIN
            --If new value for @Lines length will be > then the
            --set length then insert current contents of @line
            --and proceed.
            
            While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos-@BasePos + @LFCR) > @DefinedLength
            BEGIN
                SELECT @AddOnLen = @DefinedLength-(isnull(LEN(@Line),0) + @BlankSpaceAdded)
                INSERT #CommentText VALUES
                ( @LineId,
                  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                SELECT @Line = NULL, @LineId = @LineId + 1,
                       @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
            END
            SELECT @Line    = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2
            INSERT #CommentText VALUES( @LineId, @Line )
            SELECT @LineId = @LineId + 1
            SELECT @Line = NULL
        END
        ELSE
        --else carriage return not found
        BEGIN
            IF @BasePos <= @TextLength
            BEGIN
                --If new value for @Lines length will be > then the
                --defined length
                --
                While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
                BEGIN
                    SELECT @AddOnLen = @DefinedLength - (isnull(LEN(@Line),0) + @BlankSpaceAdded)
                    INSERT #CommentText VALUES
                    ( @LineId,
                      isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                    SELECT @Line = NULL, @LineId = @LineId + 1,
                        @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
                END
                SELECT @Line = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')
                if LEN(@Line) < @DefinedLength and charindex(' ', @SyscomText, @TextLength+1 ) > 0
                BEGIN
                    SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
                END
            END
        END
    END

	FETCH NEXT FROM ms_crs_syscom into @SyscomText
END

IF @Line is NOT NULL
    INSERT #CommentText VALUES( @LineId, @Line )

select Text from #CommentText order by LineId

CLOSE  ms_crs_syscom
DEALLOCATE 	ms_crs_syscom

DROP TABLE 	#CommentText

-- -------------------------------------
-- End of extract from sp_helptext
-- -------------------------------------

-- Drop the procedure that was setup with dashes and rebuild it with the good stuff
EXECUTE ('drop PROCEDURE '+ @procedure)

EXECUTE (@real_decrypt_01 + @real_decrypt_02 + @real_decrypt_03 +@real_decrypt_04 + @real_decrypt_05 + @real_decrypt_06 + @real_decrypt_07 + @real_decrypt_08 + @real_decrypt_09 + @real_decrypt_10)


DROP TABLE  #output
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

