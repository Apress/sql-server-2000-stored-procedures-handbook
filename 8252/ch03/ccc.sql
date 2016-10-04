--=================================================================================================
--  Concurrency ; Optimistic locking
--=================================================================================================

----------------------------------------------------------------------------------------------------
-- using a manually coded optimistic lock
----------------------------------------------------------------------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'person') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table person
GO
CREATE TABLE person
(
     personId int IDENTITY(1,1),
     firstName varchar(60) NOT NULL,
     middleName varchar(60) NOT NULL,
     lastName varchar(60) NOT NULL,
     dateOfBirth datetime NOT NULL,
     rowLastModifyDate datetime NOT NULL default getdate(),
     rowModifiedByUserIdentifier nvarchar(128) NOT NULL 
        default suser_name()
     ,constraint XPKperson primary key (personId)  
)

Go

----------------------------------------------------------------------------------------------------
-- Implementing the instead of trigger for rowModification indicators
----------------------------------------------------------------------------------------------------

CREATE TRIGGER person$insteadOfUpdate on person
INSTEAD OF UPDATE
AS

DECLARE @numRows integer
SET     @numRows = @@rowcount 

IF @numRows = 0
   RETURN

SET NOCOUNT ON --must come after the @@rowcount setting

DECLARE @msg varchar(8000) --holding for output message

UPDATE person
SET firstName = inserted.firstName,
        middleName = inserted.middleName,
        lastName = inserted.lastName,
        dateOfBirth = inserted.dateOfBirth,
        rowLastModifyDate = getdate(),
        rowModifiedByUserIdentifier = suser_name()
FROM inserted
   join person
           on person.personId = inserted.personId
IF @@error <> 0
 BEGIN
         SET     @msg = 'There was a problem in the instead of trigger 
                        for the update of person record(s).'         
  RAISERROR 50000 @msg
         ROLLBACK TRANSACTION
         RETURN
 END

go


----------------------------------------------------------------------------------------------------
-- Implementing the procedure to deal with the manually coded optimistic lock
----------------------------------------------------------------------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.person$upd') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.person$upd
GO

CREATE PROCEDURE person$upd
(
    --primary key
    @r_personId int,

    --updateable fields
    @firstName varchar(60)  ,
    @middleName varchar(60)  ,
    @lastName varchar(60)  ,
    @dateOfBirth datetime  ,

    --optimistic lock
    @rowModifiedByUserIdentifier nvarchar(128)  = null
)
as

--  Turns off the message returned at the end of each statement 
--  that states how many rows were affected 
SET NOCOUNT ON

 begin
   DECLARE  @rowcount int,  --checks the rowcount returned     
     @error   int,  --used to hold the error code after a call
     @msg   varchar(255), --used to preformat error messages
            @retval   int,    --general purpose var for return values
     @savepoint varchar(30) --holds the transaction name

   SET     @savepoint = cast(object_name(@@procid) as varchar(27)) 
			      + cast(@@nestlevel as varchar(3))
    begin transaction
    save transaction @savepoint

    UPDATE  person
       SET  firstName = @firstName ,
            middleName = @middleName ,
            lastName = @lastName ,
            dateOfBirth = @dateOfBirth
     WHERE  personId = @r_personId 
       and  rowModifiedByUserIdentifier = @rowModifiedByUserIdentifier 

    --get the rowcount and error level for the error handling code
    SELECT @rowcount = @@rowcount, @error = @@error

    IF @error != 0  --an error occurred outside of this procedure
      BEGIN
 	SELECT @msg = 'Problem occurred modifying the person record.'  
        RAISERROR 50001 @msg
        ROLLBACK TRANsACTION @savepoint
	COMMIT TRANSACTION
        RETURN -100
      END
    ELSE 
        IF (@rowcount = 0 ) 
         BEGIN
                --check existance
                IF EXISTS ( SELECT *
                           FROM   person
                            WHERE   personId = @r_personId )
                  BEGIN
                       SELECT @msg = 'The person record you tried to modify has been modified by another user.'
                  END
                ELSE
                  BEGIN
                       SELECT @msg = 'The person record you tried to modify does not exist.'
                  END

	        RAISERROR 50001 @msg
	        ROLLBACK TRANSACTION @savepoint
	        COMMIT TRANSACTION
	        RETURN -100
          END


    COMMIT TRAN
    RETURN 0
 END
go

----------------------------------------------------------------------------------------------------
-- Implementing the procedure to deal with the timestamp optimistic lock
----------------------------------------------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'person') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table person
GO



Create table person
(
     personId int IDENTITY(1,1),
     firstName varchar(60) NOT NULL,
     middleName varchar(60) NOT NULL,
     lastName varchar(60) NOT NULL,
     dateOfBirth datetime NOT NULL
    ,autoTimestamp timestamp not null
    ,constraint XPKperson primary key (personId)  
)
go

----------------------------------------------------------------------------------------------------
-- Re-Implementing the procedure to deal with the timestamp optimistic lock
----------------------------------------------------------------------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.person$upd') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.person$upd
GO


CREATE PROCEDURE person$upd
(
    --primary key
    @r_personId int,

    --updateable fields
    @firstName varchar(60)  ,
    @middleName varchar(60)  ,
    @lastName varchar(60)  ,
    @dateOfBirth datetime  ,

    --optimistic lock
    @autoTimestamp timestamp  = null
)
as

--  Turns off the message returned at the end of each statement 
--  that states how many rows were affected 
SET NOCOUNT ON

 begin
   DECLARE  @rowcount int,  --checks the rowcount returned     
     @error   int,  --used to hold the error code after a call
     @msg   varchar(255), --used to preformat error messages
     @retval   int,    --general purpose var for return values
     @savepoint varchar(30) --holds the transaction name

   SET     @savepoint = cast(object_name(@@procid) as varchar(27)) 
			      + cast(@@nestlevel as varchar(3))
    begin transaction
    save transaction @savepoint

    UPDATE  person
       SET  firstName = @firstName ,
            middleName = @middleName ,
            lastName = @lastName ,
            dateOfBirth = @dateOfBirth
     WHERE  personId = @r_personId 
       and  autoTimestamp = @autoTimestamp

    --get the rowcount and error level for the error handling code
    SELECT @rowcount = @@rowcount, @error = @@error

    IF @error != 0  --an error occurred outside of this procedure
      BEGIN
 	SELECT @msg = 'Problem occurred modifying the person record.'  
        RAISERROR 50001 @msg
        ROLLBACK TRANsACTION @savepoint
	COMMIT TRANSACTION
        RETURN -100
      END
    ELSE 
     BEGIN
        IF (@rowcount = 0 ) 
         BEGIN
                --check existance
                IF EXISTS ( SELECT *
                           FROM   person
                            WHERE   personId = @r_personId )
                  BEGIN
                       SELECT @msg = 'The person record you tried to modify has been modified by another user.'
                  END
                ELSE
                  BEGIN
                       SELECT @msg = 'The person record you tried to modify does not exist.'
                  END
          END

        RAISERROR 50001 @msg
        ROLLBACK TRANSACTION @savepoint
        COMMIT TRANSACTION
        RETURN -100
    END

    COMMIT TRAN
    RETURN 0
 END
go
