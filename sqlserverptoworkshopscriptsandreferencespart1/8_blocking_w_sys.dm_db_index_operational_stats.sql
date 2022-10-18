/* This Sample Code is provided for the purpose of illustration only and is not intended
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or
result from the use or distribution of the Sample Code.*/

/*In order to see the main objects of blocking contention, the following code lists the 
table and index with most blocks:
----Find Row lock waits*/
DECLARE  @dbid INT 

SELECT @dbid = Db_id() 

SELECT   dbid = database_id, 
         objectname = Object_name(s.object_id), 
         indexname = i.name, 
         i.index_id  --, partition_number 
         , 
         row_lock_count, 
         row_lock_wait_count, 
         [block %] = Cast(100.0 * row_lock_wait_count / (1 + row_lock_count) AS NUMERIC(15,2)), 
         row_lock_wait_in_ms, 
         [avg row lock waits in ms] = Cast(1.0 * row_lock_wait_in_ms / (1 + row_lock_wait_count) AS NUMERIC(15,2)) 
FROM     sys.Dm_db_index_operational_stats(@dbid,NULL,NULL,NULL) s, 
         sys.indexes i 
WHERE    Objectproperty(s.object_id,'IsUserTable') = 1 
         AND i.object_id = s.object_id 
         AND i.index_id = s.index_id 
ORDER BY row_lock_count DESC 

/*Notice the average block time reported in the above script is in milliseconds. You must convert the 
average block time to seconds in order to set the ‘blocked process threshold’ with sp_configure.  
This should give you a hint on how to set the sp_configure ‘blocked process threshold’ if you are not 
sure where to start. Remember not to set the blocked process threshold (seconds) too low as this will 
generate false positives.  The blocked process threshold fires a trace event (Blocked Process Report) 
for any block that exceeds the configured number of seconds.*/
