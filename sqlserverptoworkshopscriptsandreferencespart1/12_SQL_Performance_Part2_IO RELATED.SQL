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
--I/O RELATED
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/*1). sys.dm_io_pending_io_requests

It is important to recongize that these are current active waits that are I/O related. See Books 
Online for more on the DMVS.*/

SELECT database_id
	, file_id
	, io_stall, io_pending_ms_ticks
	, scheduler_address
FROM sys.dm_io_virtual_file_stats (NULL,NULL) as t1
JOIN sys.dm_io_pending_io_requests as t2
on t1.file_handle = t2.io_handle


/*2). The query below can be used to determine if pending IO is causing work to be queued on the 
scheduler. See Books Online for more.*/

SELECT DataBase_Id,
       File_Id,
       io_Stall,
       io_Pending_ms_Ticks,
       t2.Scheduler_Address,
       t3.RunNable_Tasks_Count,
       t3.Work_Queue_Count
FROM   sys.Dm_io_virtual_file_stats (NULL,NULL ) AS t1
       JOIN sys.dm_io_Pending_io_Requests AS t2
         ON t1.File_Handle = t2.io_Handle
       JOIN sys.dm_os_Schedulers t3
         ON t2.Scheduler_Address = t3.Scheduler_Address
