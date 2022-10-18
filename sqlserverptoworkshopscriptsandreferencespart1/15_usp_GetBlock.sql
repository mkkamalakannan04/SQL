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

USE [msdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_getblock]    Script Date: 03/01/2007 13:27:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_getblock] @threshhold int = 2

as

set nocount on 

if @threshhold < (select count(*) from sys.sysprocesses where blocked > 0)
begin 
	SELECT sp.spid,
		sp.last_batch,
		sp.waittype,
		sp.open_tran,
		sp.hostname,
		sp.nt_username,
		sp.loginame,
		sp.program_name,
		(select text from sys.sysprocesses as p 
		cross apply sys.dm_exec_sql_text(p.sql_handle)
	where p.spid = sp.spid) AS sql_statement 
	FROM SYS.sysprocesses sp 
		WHERE sp.spid IN (SELECT blocked
			FROM SYS.sysprocesses WHERE spid IN 
				(SELECT blocked 
					FROM SYS.sysprocesses WHERE blocked <> 0)) 
	print char(13)

	PRINT 'Processes Blocked.'
	select t1.resource_type
		,db_name(resource_database_id) as [database]
		,t1.resource_associated_entity_id as [blk object]
		,t1.request_mode
		,t1.request_session_id -- spid of waiter
		,(select text from sys.dm_exec_requests as r --- get sql for waiter
			cross apply sys.dm_exec_sql_text(r.sql_handle) where r.session_id = t1.request_session_id) as waiter_text
		,t2.blocking_session_id -- spid of blocker
		,(select text from sys.sysprocesses as p --- get sql for blocker
			cross apply sys.dm_exec_sql_text(p.sql_handle) where p.spid = t2.blocking_session_id) as blocker_text
	from sys.dm_tran_locks as t1, 
		sys.dm_os_waiting_tasks as t2
	where t1.lock_owner_address = t2.resource_address
end

