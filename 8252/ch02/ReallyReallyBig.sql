SET NOCOUNT ON

CREATE TABLE ReallyReallyBig 
  (
   IDCol INT NOT NULL,
   VarCharCol VARCHAR (255) NOT NULL 
  )

CREATE TABLE ReallyReallyLittle 
  (
   IDCol INT NOT NULL ,
   VarCharCol VARCHAR (255) NOT NULL
  )

DECLARE @Count INT
SELECT @Count=1

WHILE @Count<=10000
BEGIN
  -- Insert a row with some nonsensical character data
  INSERT ReallyReallyBig(IDCol, VarCharCol)
  VALUES(@Count,REPLICATE(CHAR((@Count % 26)+64),@Count % 255))
  SELECT @Count=@Count+1
END

INSERT ReallyReallyLittle(IDCol, VarCharCol) 
VALUES(9999,'ABC')
