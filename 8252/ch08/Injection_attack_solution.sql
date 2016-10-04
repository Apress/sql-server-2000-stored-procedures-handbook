SET QUOTED_IDENTIFIER OFF
DECLARE @InputText varchar(100),
        @command varchar(1000)
SELECT @InputText = "' ; INSERT INTO jobs (job_desc, min_lvl, max_lvl)
VALUES ('Important Job',25,100) --"

SELECT @InputText = 
REPLACE(@InputText,"'","''")
SELECT @InputText AS 'InputText.Text'
SELECT @command = "select au_fname,au_lname from authors 
WHERE au_id = '" + @InputText + "'"
SELECT @command AS 'Executable SQL Command'
EXEC (@command)
