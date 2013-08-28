BULK INSERT TableName
FROM 'File.txt'
WITH (
	FIELDTERMINATOR = ','
	,ROWTERMINATOR = '0x0a'
	-- If the data starts at a certain row, input here
	,FIRSTROW=2
	-- If the data end at a certain row
	,LASTROW=1000000
	-- Logs any rows of data causing an error (very useful for debugging)
	,ERRORFILE='C:\logfile.log')
GO
