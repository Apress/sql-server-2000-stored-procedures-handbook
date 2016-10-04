CREATE TABLE [dbo].[syscomments] 
  (
    [id] [INT] NOT NULL ,
    [number] [SMALLINT] NOT NULL ,
    [colid] [SMALLINT] NOT NULL ,
    [status] [SMALLINT] NOT NULL ,
    [ctext] [VARBINARY] (8000) NOT NULL ,
    [texttype] AS (CONVERT(SMALLINT, (2 + 4 * ([status] & 1)))) ,
    [language] AS (CONVERT(SMALLINT,0)) ,
    [encrypted] AS (CONVERT(BIT,([status] & 1))) ,
    [compressed] AS (CONVERT(BIT,([status] & 2))) ,
    [text] AS (CONVERT(NVARCHAR(4000),
    case IF ([status] & 2 = 2) THEN (uncompress([ctext])) ELSE 
    [ctext] END)) 
  )
ON [PRIMARY]
