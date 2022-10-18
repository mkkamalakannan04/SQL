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

/*New in SQL Server 2008 R2 Service Pack 1 and SQL Server 2012 is the following columns:

total_rows
last_rows
min_rows
max_rows

This information can be very useful when trying to track volume between executions 
including the average number of records. A common need for this is in a reporting 
/ data processing environment where the volume of records
can easily slow down reporting. When you are trying to discern what is slowing down 
a report, it is very useful to be
able to track the number of records over time.

Below is an example of how these new columns added to SQL Server 2008 SP1 (CTP) can 
be leveraged:*/

SELECT
TOP 10 qs.*, (total_rows/execution_count) AS AVG_ROWS, execution_count, 
qp.query_plan, st.text
FROM
sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
--SPECIFY A TIMEFRAME TO GATHER CACHED DATA
WHERE DATEDIFF(hour, last_execution_time, getdate()) < 1 -- change hour time frame
--CHANGE THE ORDER BY TO GET THE TOP 10 for DIFFERENT RESOURCES
ORDER BY (total_rows/execution_count) DESC;

