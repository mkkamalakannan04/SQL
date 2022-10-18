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

/*15). Below is an interesting query. That can be used for many situations. From a disk point of view 
this is one of the most powerful. You can use this query to find which databases have the highest 
number of io_stalls or waits for the users must tolerate, you can get this information for all stalls, 
reads, and writes. You can also get this information at the file level within the database. Also, 
through a trick mapping back to sys.Master_Files and using the SUBSTRING function, you can find the 
io_stalls per disk. PER DISK!?! Think about that. You have a SAN, which many different disks separated 
for many different databases and files. Did you do it correctly? Did you accidentally put too many io 
resource consuming databases and files on the same disks? You can find that out from here too.

Now imagine taking this query and building a SQL Server Reporting Services Report focusing the Database,
Data Files, and Disk Location io_stalls, by reads, writes and total io_stalls. The data this could give
you would allow you to make decisions on placement of tables into files & filegroups and can help you
identify hotspots with real hard numbers.*/

SELECT a.io_stall, a.io_stall_read_ms, a.io_stall_write_ms, a.num_of_reads,
 a.num_of_writes,
--a.sample_ms, a.num_of_bytes_read, a.num_of_bytes_written, a.io_stall_write_ms,
 ( ( a.size_on_disk_bytes / 1024 ) / 1024.0 ) AS size_on_disk_mb,
 db_name(a.database_id) AS dbname,
 b.name, a.file_id,
 db_file_type = CASE
                    WHEN a.file_id = 2 THEN 'Log'
                   ELSE 'Data'
                   END,
 UPPER(SUBSTRING(b.physical_name, 1, 2)) AS disk_location
 FROM sys.dm_io_virtual_file_stats (NULL, NULL) a
 JOIN sys.master_files b ON a.file_id = b.file_id
 AND a.database_id = b.database_id
 ORDER BY a.io_stall DESC 

 /* sys.dm_io_virtual_file_stats columns (FROM BOL)

*sample_ms* - Number of milliseconds since the computer was started. This column can be used to compare 
different outputs from this function.
*num_of_reads* - Number of reads issued on the file.
*num_of_bytes_read* - Total number of bytes read on this file.
*io_stall_read_ms* - Total time, in milliseconds, that the users waited for reads issued on the file.
*num_of_writes* - Number of writes made on this file.
*num_of_bytes_written* - Total number of bytes written to the file.
*io_stall_write_ms* - Total time, in milliseconds, that users waited for writes to be completed on the 
file.
*io_stall* - Total time, in milliseconds, that users waited for I/O to be completed on the file.
*size_on_disk_bytes* - Number of bytes used on the disk for this file. For sparse files, this number is 
the actual number of bytes on the disk that are used for database snapshots.*/