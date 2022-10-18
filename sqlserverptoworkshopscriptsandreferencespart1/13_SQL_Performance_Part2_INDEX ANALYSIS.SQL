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

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--INDEX ANALYSIS
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--SYS.DM_DB_PHYSICAL_STATS
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

--1).The query below lists the indexes which are fragmented by more than 30% in the current database

SELECT
	object_name(ps.object_id) AS object_name,
	si.name AS index_name,
	partition_number AS partitionnum,
	avg_fragmentation_in_percent AS frag
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') as ps
JOIN sys.indexes as si on ps.object_id = si.object_id and ps.index_id = si.index_id
WHERE avg_fragmentation_in_percent > 30.0 AND ps.index_id > 0
ORDER BY frag DESC


/*2). In the query below, rarely uses indexes appear first. 
NOTE: Keep in mind this is tracked since SQL Server was last started, in other words, if you start 
dropping indexes and you rebooted your server last night. You probably will regret your decision.

IMPORTANT: Make sure you run and make decisions on this based on the server running for a significant
amount of time based on your environment. Additionally, instead of dropping indexes, it is recommended
to disable them to make sure it doesn't cause a problem. You can always reenable them by choosing to
rebuild the index via SSMS.

Additionally, when you decide it is okay to drop your index script it out first. Just in case you find
out that your decision was a poor one. You could then always bring it back easily.*/

USE AdventureWorks2012
go
declare @dbid int
select @dbid = db_id()
select objectname=object_name(s.object_id), s.object_id, indexname=i.name, i.index_id, user_seeks, 
user_scans, user_lookups, user_updates
from sys.dm_db_index_usage_stats s join sys.indexes i
on i.object_id = s.object_id and i.index_id = s.index_id
where database_id = @dbid and objectproperty(s.object_id, 'IsUserTable') = 1
order by (user_seeks + user_scans + user_lookups + user_updates) asc




