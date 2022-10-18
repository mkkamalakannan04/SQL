/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/

--WARNING: THIS IS RUN AGAINST ALL DBS, RECOMMENDED FOR LOW USE, NON-CRITICAL ENVRIONMENTS

SET NOCOUNT on
DECLARE @dname sysname


Begin
	DECLARE CheckDBs CURSOR FAST_FORWARD FOR 
	SELECT name from sys.databases WHERE name not in ('master', 'model', 'msdb', 'TempDB')
	open CheckDBs
	Fetch Next from CheckDBs into @dname
	While (@@fetch_status=0)
	Begin
		Print 'Processing '+Upper(Ltrim(@dname))+' database'

		Exec('Use '+@dname+' DECLARE @NewIndexes table (database_name sysname, objectid int, table_name varchar (8000), index_name varchar (8000) NULL, indexid int, 
		index_type varchar(8000),indexlevel int, fragmentation float, fragment_count int, page_count int, used_page_percent float)
		DECLARE @objectid int
		DECLARE @currentDdbId int
		DECLARE @indexid int

		-- populate the table variable with the fragmentation stats
		SELECT @currentDdbId = DB_ID()
		INSERT INTO @NewIndexes
		SELECT 
		@currentDdbID, object_id, object_name(object_id) as Name, NULL, index_id, index_type_desc, index_level, avg_fragmentation_in_percent, fragment_count, page_count, avg_page_space_used_in_percent
		FROM sys.dm_db_index_physical_stats (@currentDdbId, NULL, NULL , NULL, ''SAMPLED'')
		WHERE index_id > 0

		-- cursor time again ... probably should have used another table variable, but oh well ...	
		DECLARE @objectname sysname
		DECLARE @indexname sysname
		DECLARE indexnames CURSOR FAST_FORWARD FOR SELECT objectid,indexid FROM @NewIndexes

		OPEN indexnames;
		FETCH NEXT
		FROM indexnames
	   INTO @objectid, @indexid;

	WHILE @@FETCH_STATUS = 0
		BEGIN

		SELECT @indexname = name 
		FROM sys.indexes
		WHERE  object_id = @objectid AND index_id = @indexid
		
		UPDATE @NewIndexes
		SET index_name  = @indexname
		WHERE @objectid = objectid and @indexid =indexid
		
		FETCH NEXT FROM indexnames INTO @objectid, @indexid
	END
	CLOSE indexnames;
	DEALLOCATE indexnames;

	-- final results
	select db_name(database_name) as databasename, table_name, index_name, indexid, index_type, indexlevel, fragmentation, fragment_count, page_count, used_page_percent as percent_pages_used
	from @NewIndexes
	order by fragmentation desc
')


		Print 'Processing of ' +Upper(Ltrim(@dname))+ ' completed.'
		Print ' '
		Fetch Next from CheckDBs into @dname
	End
	Close CheckDBs
	Deallocate CheckDBs
End