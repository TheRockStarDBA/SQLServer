USE [AdminExamples]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_BackUpScript]
AS
BEGIN
	
	IF OBJECT_ID('tempdb..##DatabaseConsistency') IS NOT NULL
	BEGIN
		DROP TABLE ##DatabaseConsistency
	END

	CREATE TABLE ##DatabaseConsistency(
		Error VARCHAR(10) NULL,
		Level VARCHAR(10) NULL,
		State VARCHAR(10) NULL,
		MessageText VARCHAR(2000),
		RepairLevel VARCHAR(250) NULL,
		Status VARCHAR(10) NULL,
		DbId VARCHAR(10) NULL,
		DbFragId VARCHAR(10) NULL,
		ObjectID VARCHAR(25) NULL,
		IndexID VARCHAR(10) NULL,
		PartitionID VARCHAR(10) NULL,
		AllocUnitId VARCHAR(10) NULL,
		RidDbID VARCHAR(10) NULL,
		RidPruId VARCHAR(10) NULL,
		[File] VARCHAR(10) NULL,
		Page VARCHAR(10) NULL,
		Slot VARCHAR(10) NULL,
		RefDbId VARCHAR(10) NULL,
		RefPruId VARCHAR(10) NULL,
		RefFile VARCHAR(10) NULL,
		RefPage VARCHAR(10) NULL,
		RefSlot VARCHAR(10) NULL,
		Allocation VARCHAR(10) NULL
	)

	INSERT INTO ##DatabaseConsistency
	EXEC('DBCC CHECKDB(AdminExamples) WITH TABLERESULTS')

	/* Backup the database if integrity exists */

	DECLARE @count TINYINT

	SELECT @count = COUNT(*)
	FROM ##DatabaseConsistency
	WHERE MessageText LIKE 'CHECKDB found 0 allocation errors and 0 consistency errors%'

	IF @count > 0
	BEGIN
	
		-- Back up database
		DECLARE @db VARCHAR(100), @check TINYINT = 0
		SET @db = DB_NAME()

		BACKUP DATABASE AdminExamples
		TO DISK = 'E:\AdminExamples.BAK'
		IF @@ERROR <> 0
		BEGIN
			PRINT 'Backup failed for database ' + @db
		END
		ELSE
		BEGIN
			SET @check = 1
		END

		-- Verify the backup
		IF @check = 1
		BEGIN
			RESTORE VERIFYONLY
			FROM DISK = 'E:\AdminExamples.BAK'
		END
	
		PRINT 'Database ' + @db + ' backed up and verified ' + CAST(@count AS VARCHAR(1))
	
	END
	ELSE
	BEGIN
	
		-- CheckDB found an error
		PRINT 'Database integrity compromised'
	
	END

	DROP TABLE ##DatabaseConsistency

END
