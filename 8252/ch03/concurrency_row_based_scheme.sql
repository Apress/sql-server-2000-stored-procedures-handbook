--=================================================================================================
--  Concurrency ; Optimistic locking ; logical unit of work
--=================================================================================================


----------------------------------------------------------------------------------------------------
-- build our tables
----------------------------------------------------------------------------------------------------

--leaving off who invoice is for and other information that would just clutter up our example ;)
CREATE TABLE invoice
(
     invoiceId int IDENTITY(1,1),
     number varchar(20) NOT NULL,
     rowLastModifyDate datetime NOT NULL default getdate(),
     rowModifiedByUserIdentifier nvarchar(128) NOT NULL 
        default user_name()

     ,constraint XPKinvoice primary key (invoiceId)  
)
go
--also forgetting what product that the line item is for
CREATE TABLE invoiceLineItem
(
     invoiceLineItemId int IDENTITY(1,1) NOT NULL,
     invoiceId int NULL,
     itemCount int NOT NULL,
     cost int NOT NULL
     ,constraint XPKinvoiceLineItem primary key (invoiceLineItemId)  
)
go


----------------------------------------------------------------------------------------------------
-- Implementing the instead of trigger for rowModification indicators
----------------------------------------------------------------------------------------------------

CREATE TRIGGER invoice$insteadOfUpdate on invoice
INSTEAD OF UPDATE
AS

DECLARE @numRows integer
SET     @numRows = @@rowcount 

IF @numRows = 0 --no need to go into this trigger if no rows modified
   RETURN

SET NOCOUNT ON --must come after the @@rowcount setting

DECLARE @msg varchar(8000) --holding for output message

UPDATE invoice
SET 	number = inserted.number,
        rowLastModifyDate = getdate(),
        rowModifiedByUserIdentifier = user_name()
FROM 	inserted
          join invoice
           on invoice.invoiceId = inserted.invoiceId

select @@rowcount

IF @@error <> 0
 BEGIN
         SET     @msg = 'There was a problem in the instead of trigger 
                        for the update of invoice record(s).'         
         RAISERROR 50000 @msg
         ROLLBACK TRANSACTION
         RETURN
 END
go


----------------------------------------------------------------------------------------------------
-- Implementing our delete procedure using the logical unit of work lock
----------------------------------------------------------------------------------------------------

CREATE PROCEDURE invoiceLineItem$del
(
    @r_invoiceLineItemId int  -- just need the primary key

    --this will be the timestamp of the invoice table
    ,@rowLastModifyDate datetime
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

    --get the key of the table where we are going to get the optimistic lock in
    DECLARE @invoiceId int
    SELECT  @invoiceId = invoiceId
    FROM    invoiceLineItem
    WHERE   invoiceLineItem.invoiceLineItemId = @r_invoiceLineItemId 

    --then delete the invoice line item
    DELETE  invoiceLineItem
    FROM    invoiceLineItem
                  join invoice
                      on invoice.invoiceId = invoiceLineItem.invoiceId   
    WHERE   invoiceLineItem.invoiceLineItemId = @r_invoiceLineItemId 
      and   @rowLastModifyDate = invoice.rowLastModifyDate

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
    ELSE IF (@rowcount = 0 ) 
      BEGIN
                --check existance
           IF EXISTS ( SELECT *
                       FROM   invoiceLineItem
                       WHERE   invoiceLineItemId = @r_invoiceLineItemId )
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

    --bumps the autotimeStamp
    UPDATE  invoice
    SET	    invoice.rowLastModifyDate = getdate() --doesn't matter what value you put here, the trigger will override it
    FROM    invoice
    WHERE   invoice.invoiceId = @invoiceId 

    IF @error != 0  --an error occurred outside of this procedure
      BEGIN
 	SELECT @msg = 'Problem occurred bumping the timestamp value on the invoice row'  
        RAISERROR 50001 @msg
        ROLLBACK TRANsACTION @savepoint
	COMMIT TRANSACTION
        RETURN -100
      END
    
 
    COMMIT TRAN
    RETURN 0
 END

go
