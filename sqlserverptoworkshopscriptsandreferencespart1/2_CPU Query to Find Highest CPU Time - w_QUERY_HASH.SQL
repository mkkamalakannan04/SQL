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

--ORDER BY TOTAL WORKER TIME
SELECT TOP 10
s2.dbid, 
--s1.sql_handle, s1.plan_handle, s1.query_hash, s1.query_plan_hash, 
(SELECT TOP 1 SUBSTRING(s2.text, statement_start_offset/2, ( (CASE
WHEN statement_end_offset = -1 
THEN (LEN(CONVERT(nvarchar(max),s2.text)) * 2)
ELSE statement_end_offset END) - statement_start_offset) / 2) ) AS
sql_statement,  execution_count, total_elapsed_time, plan_generation_num, 
last_execution_time, total_worker_time, last_worker_time, min_worker_time, 
max_worker_time, total_logical_reads, total_physical_reads, last_physical_reads, 
min_physical_reads, max_physical_reads,total_logical_writes, last_logical_writes, 
min_logical_writes, max_logical_writes
FROM sys.dm_exec_query_stats s1
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2
WHERE (s2.objectid is null)
ORDER BY total_worker_time DESC
