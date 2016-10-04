-- ----------------------------------------------------------
-- Password generator script - Good for SQL 7 and SQL 2000 passwords
-- ----------------------------------------------------------

set nocount on
declare  @counter   int,
         @password  varchar(128),
         @char      char(1),
         @charindex int,
         @loop      int

select @counter = 1
select @password = ''
while @counter < 2
begin
        --Restrict the password to 0-9, A-Z, and a-z
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if @charindex between 65 and 90 or @charindex between 97 and 122
				--or @charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
while @counter < 4
begin
        --Restrict the password to 0-9, A-Z, and a-z
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if @charindex between 48 and 57 or @charindex between 65 and 90 or @charindex between 97 and 122
				--or @charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
while @counter < 5
begin
        --Restrict the password to 0-9
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if @charindex between 48 and 57 --or @charindex between 65 and 90 or @charindex between 97 and 122
				--or @charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
while @counter < 10
begin
        -- Restrict the password to NOT 0-9, A-Z, and a-z
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if --@charindex between 48 and 57 or @charindex between 65 and 90 or @charindex between 97 and 122
				--or 
			@charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
while @counter < 11
begin
        --Restrict the password to 0-9
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if @charindex between 48 and 57 --or @charindex between 65 and 90 or @charindex between 97 and 122
				--or @charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
while @counter < 129
begin
        --Restrict the password to 0-9, A-Z, and a-z
	select @loop = 1
	while @loop = 1
	begin
          select @charindex = convert(int, rand() * 254)
		if @charindex between 48 and 57 or @charindex between 65 and 90 or @charindex between 97 and 122
				or @charindex between 161 and 255 or @charindex between 130 AND 140
		     select @loop = 0
        end

        --Accumulate characters for password string
	select @char = char(@charindex)
	select @password = @password + @char
	select @counter = @counter + 1
end
select RTRIM(@password) AS Password




