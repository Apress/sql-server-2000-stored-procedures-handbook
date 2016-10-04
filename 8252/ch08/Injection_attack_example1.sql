-- Set quoted identifiers OFF so that double-quote work  like in VB or
-- VBScript code
SET QUOTED_IDENTIFIER OFF
DECLARE @InputText VARCHAR(100), 
        @command VARCHAR(1000)

-- Imagine that the application is capturing the InputText.Text
-- variable
SELECT @InputText = "527-72-3246"
SELECT @InputText AS 'InputText.Text'

-- Now, imagine that app is VB or VBScript and piecing together a SQL
-- command. The final command is represented by @command
SELECT @command = "select au_fname, au_lname from authors 
WHERE au_id = '" + @InputText + "'"

SELECT @command AS 'Executable SQL Command'
-- Imagine that we pass the command to SQL:
EXEC (@command)
