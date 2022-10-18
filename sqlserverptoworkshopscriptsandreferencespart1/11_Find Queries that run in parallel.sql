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

/*1). Queries that run in Parallel can be found with the two queries below, which approaches the issue 
in two different ways. Remember, if a query runs in parallel it is a query that SQL Server thinks is 
expensive enough to run in parallel. MAX_DOP and the cost_threshold_for_parallelism drive the behavior. 
MAX_DOP should be configured to match the number of physical processors in the server. 
Read more on this in SQL BOL.*/

SELECT 
p.*, 
q.*, 
cp.plan_handle
FROM sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_query_plan(cp.plan_handle) p
cross apply sys.dm_exec_sql_text(cp.plan_handle) as q
WHERE
cp.cacheobjtype = 'Compiled Plan' and
p.query_plan.value('declare namespace
p="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; max(//p:RelOp/@Parallel)', 'float') > 0

/*2). Another example of finding queries that run in parallel. When you find them look for ways to 
make them run more efficiently if they are run often and their performance during business hours is 
critical. Check indexing in DTA simplfy the query, remove ORDER BYs, GROUP BYs, if they arent 
necessary, etc.*/

select 
qs.sql_handle, 
qs.statement_start_offset, 
qs.statement_end_offset, 
q.dbid,
q.objectid,
q.number,
q.encrypted,
q.text
from sys.dm_exec_query_stats qs
	cross apply sys.dm_exec_sql_text(qs.plan_handle) as q
where qs.total_worker_time > qs.total_elapsed_time
