set nocount on
go
create table #donation
(
	donationId	int	identity,
	donorId		int,	--fkey to donor table
	amount		money,
	date		smalldatetime,
	processedFlag	bit default 0
)

insert into #donation (donorId, amount, date)
values (1, 100, 'december 12, 2002 10:30 am')
insert into #donation (donorId, amount, date)
values (23, 50, 'december 12, 2002 10:45 am')
insert into #donation (donorId, amount, date)
values (25, 20, 'december 12, 2002 10:50 am')
go
create procedure donation$processNew
(
	@donationId	int
) as
 begin
	update 	#donation
	set	processedFlag = 1
	where	donationId = @donationId

 end

go

--declare our cursor which will contain the keys of the #holdOutput table
declare	@donorCursor cursor
set	@donorCursor = cursor fast_forward for 	select 	donationId
						from	#donation
--open the cursor
open 	@donorCursor

--variable to fetch into
declare @donationId int, @returnValue int, @message varchar(1000)

fetch @donorCursor into @donationId

while @@fetch_status = 0
 begin
	begin transaction

	execute @returnValue = donation$processNew @donationId

	if @@error <> 0 OR @returnValue < 0
	 begin
		rollback transaction
		set @message = 'Donation ' + cast(@donationId as varchar(10)) + ' failed.'
		raiserror 50001 @message
	 end
	else
	 begin
		commit transaction	
	 end

	fetch	next from @donorCursor into @donationId
 end


CLOSE @donorCursor
DEALLOCATE @donorCursor
DROP TABLE #donation

go
drop procedure donation$processNew



