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

/*Finding the Cumulative Cost of Queries

The following example returns information about the top five queries according to 
average CPU time. This example aggregates the queries according to their query hash so 
that logically equivalent queries are grouped by their cumulative resource consumption.*/ 

USE AdventureWorks2012;
GO
SELECT TOP 5 query_stats.query_hash AS "Query Hash", 
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",
    MIN(query_stats.statement_text) AS "Statement Text"
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;
GO


/*The following example returns information about the top five query plans according to 
average CPU time. This example aggregates the queries according to their query plan hash 
so that queries with the same query plan hash are grouped by their cumulative resource 
consumption.*/ 

USE AdventureWorks2012;
GO
SELECT TOP 5 query_plan_hash AS "Query Plan Hash",
    SUM(total_worker_time)/SUM(execution_count) AS "Avg CPU Time",
    MIN(CAST(query_plan as nvarchar(max))) AS "ShowPlan XML"
FROM sys.dm_exec_query_stats AS QS CROSS APPLY 
    sys.dm_exec_query_plan(QS.plan_handle)
GROUP BY query_plan_hash
ORDER BY 2 DESC;
GO

/*For example, after changing the system configuration, you can compare query plan hash values for mission-critical queries 
to their original query plan hash values. Differences in query plan hash values can tell you if the system configuration change 
resulted in updated query execution plans for important queries. You might also decide to stop execution for a current long-running query 
if its query plan hash in sys.dm_exec_requests differs from its baseline query plan hash, which is known to have good performance.*/ 