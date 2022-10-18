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

/*Returns aggregate performance statistics for cached stored procedures. The view contains one row 
per stored procedure, and the lifetime of the row is as long as the stored procedure remains cached. 
When a stored procedure is removed from the cache, the corresponding row is eliminated from this 
view. At that time, a Performance Statistics SQL trace event is raised similar to 
sys.dm_exec_query_stats.*/

SELECT TOP 10 d.object_id, d.database_id, s.name, s.type_desc,
d.cached_time, d.last_execution_time, d.total_elapsed_time, d.total_logical_reads, 
d.total_logical_writes, d.total_physical_reads, d.total_worker_time,
d.total_physical_reads/d.execution_count AS [avg_physical_reads], 
d.last_elapsed_time, d.execution_count
FROM sys.procedures s
INNER JOIN sys.dm_exec_procedure_stats d
ON s.object_id = d.object_id
ORDER BY [total_worker_time] DESC;
GO

/*Returns aggregate performance statistics for cached triggers. The view contains one row per 
trigger, and the lifetime of the row is as long as the stored procedure remains cached. When a 
stored procedure is removed from the cache, the corresponding row is eliminated from this view. At 
that time, a Performance Statistics SQL trace event is raised similar to sys.dm_exec_query_stats.
*/
SELECT TOP 10 d.object_id, d.database_id, db_name(database_id) 'db name', 
object_name (object_id, database_id) 'proc name', d.cached_time, 
d.last_execution_time, d.total_elapsed_time, 
d.total_elapsed_time/d.execution_count AS [avg_elapsed_time], 
d.last_elapsed_time, d.execution_count
from sys.dm_exec_trigger_stats d
ORDER BY [total_worker_time] DESC;
GO

--Examine the new DMVs in 2008: sys.dm_exec_procedure_stats sys.dm_exec_trigger_stats