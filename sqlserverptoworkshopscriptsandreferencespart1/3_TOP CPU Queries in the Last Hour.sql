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

--USING DATEDIFF CAN IDENTIFY QUERIES IN A SPECIFIC WINDOW
SELECT TOP 10 
last_execution_time, total_worker_time AS [Total CPU Time], execution_count, plan_generation_num, total_elapsed_time AS Duration,
total_logical_reads, total_worker_time/execution_count AS [Avg CPU Time], 
text, qp.query_plan 
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp 
WHERE DATEDIFF(hour, last_execution_time, getdate()) < 1 -- change hour time frame 
ORDER BY total_worker_time DESC; 
