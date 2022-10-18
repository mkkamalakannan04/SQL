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

--1). CALCUALTING TOTAL SIGNAL WAIT TIME (CPU BOTTLENECK)

/*You generally have a CPU bottleneck if Signal Waits > 25% - Time in runnable queue is 
pure CPU waits. The script below will show Signal Wait time as a percentage*/

SELECT SignalWaitTimems = SUM(Signal_Wait_Time_ms),
       '%signal waits' = CAST(100.0 * SUM(Signal_Wait_Time_ms) / SUM(Wait_Time_ms) AS NUMERIC(20,2)),
       ResourceWaitTimems = SUM(Wait_Time_ms - Signal_Wait_Time_ms),
       '%resource waits' = CAST(100.0 * SUM(Wait_Time_ms - Signal_Wait_Time_ms) 
		/ SUM(Wait_Time_ms) AS NUMERIC(20,2))
FROM   sys.dm_os_wait_stats

--2). RESOURCE QUEUE - PARALLELISM EXAMPLE (CPU BOTTLENECK)

/*You generally have a resource bottleneck with Parallelism if CXPACKET waits are > 10% - 
Parallelism reduces OLTP throughput. CXPACKET indicates that multiple CPUs are working in 
parallel, dividing up the query in smaller pieces.

Ordinarily a well tuned OLTP application would not parallelize unless an index is missing,
there is an incomplete WHERE clause, or the query is not a true OLTP transaction.

Keep this in mind, SQL Server will use Parallelism if it considers the query to be 
expensive enough to run over multiple CPUs. This is an important point to realize for later*/

SELECT wait_type, wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type = 'CXPACKET'

--3a). THE FOLLOWING DMV QUERY CAN BE USED TO FIND CURRENT I/O LATCH WAIT STATISTICS.

/*Compare this to the percentage of the other wait types. It is important to read through the two white
papers I included in my email. In this case, when looking at the *sys.dm_os_wait_stats* DMV look at the
wait statistics whitepaper. Any time you see a wait type that you don't know, look it up there*/

SELECT   Wait_Type,
         Waiting_Tasks_Count,
         Wait_Time_ms
FROM     sys.dm_os_wait_stats
WHERE    Wait_Type LIKE 'PAGEIOLATCH%'
ORDER BY Wait_Type

/*3b). IS MY SYSTEM CAN BE POSSIBLY BOTTLENECKED ON I/O? 

You can answer this question by looking at the wait type of tasks waiting on specifically you are 
interested in IO waits.

Note: Adjust the Wait Duration Based on your disk subsystem*/

SELECT *
FROM   sys.dm_os_WaitIng_Tasks
WHERE  Wait_Duration_ms > 10
       AND Wait_Type LIKE '%PAGEIOLATCH%'


/*4). THIS QUERY LISTS THE TOP 10 WAITS IN SQL SERVER. 

These waits are cumulative but you can reset them using DBCC SQLPERF ([sys.dm_os_wait_stats], clear).
You can see more on that command from SQL Server Books Online.*/

SELECT   TOP 10 *
FROM     sys.dm_os_Wait_sTats
ORDER BY Wait_Time_ms DESC

/* WHAT DO THESE WAIT TYPES MEAN? This is a good reference as well, but the whitepaper in my email is
beyond what you will find here.*/
http://msdn2.microsoft.com/en-us/library/ms179984.aspx


xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--SYS.DM_OS_WAIT_STATS 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/*5).sys.dm_os_wait_stats 
This view returns information about the waits encountered by threads that are in execution. It is 
important to remember that the information in this DMV is cumulative since SQL Server has been running. 
Specific types of wait times during query execution can indicate bottlenecks within the query. 
For example, lock waits indicate data contention by queries; page I/O latch waits indicate slow I/O 
response times; page latch update waits indicate incorrect file layout. The statistics returned 
indicate the wait information since SQL Server was last restarted.

See the previous emailed whitepaper and queries on more about wait statistics.

It is important to look at the new SQL Server 2008 Wait Types I outlined for you and at least be aware 
of them.*/

SELECT * FROM sys.dm_os_wait_stats

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--SYS.DM_OS_WAITING_TASKS 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/*6). sys.dm_os_waiting_tasks - This view returns sessions that are waiting on a resource, that is 
anything in the Waiter List Queue. This is similar to querying sys.processes and looking for rows with 
a non-zero waittype or blocked > 0. This means that this DMV is real time, and is not cumulative.

If there is blocking, the blocking_session_id column with be > 0 and the resource_description column 
will have additional information.

How many tasks are currently waiting?*/
 
SELECT COUNT(* )
FROM   sys.dm_os_Waiting_Tasks

/*7). This query shows how many threads are actively running in the system and what the tasks are 
waiting on.*/
 
SELECT   Wait_Type,
         COUNT(* )
FROM     sys.dm_os_waiting_tasks
GROUP BY Wait_Type
ORDER BY COUNT(* ) DESC

/*8). Does my load have an active resource bottleneck?
You can answer this question by looking at the resource address that tasks are blocked on.  

Keep in mind that not all wait types have resource associated with them.*/

SELECT   wait_type, Resource_Address,
         COUNT(* )
FROM     sys.dm_os_Waiting_Tasks
WHERE    Resource_Address <> 0
GROUP BY Resource_Address, wait_type
ORDER BY COUNT(* ) DESC

/*9). Is my system can be possibly bottlenecked on I/O?

You can answer this question by looking at the wait type of tasks waiting on 
specifically you are interested in IO waits*/

SELECT *
FROM   sys.dm_os_Waiting_Tasks
WHERE  Wait_Duration_ms > 10
       AND Wait_Type LIKE '%PAGEIOLATCH%'

--NOTE: In SQL Server 2008 there is a new wait type called WRITE_COMPLETION 
--which occurs when a write operation is in progress. It is important to
--look at this too on SQL Server 2008 machines.


