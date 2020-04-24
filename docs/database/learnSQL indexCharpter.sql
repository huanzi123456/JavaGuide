-/*sql优化 
 https://www.jianshu.com/p/2bca7e9c2ad0
*/

关系型数据库: 
  索引方法 B树索引,hash索引!    https://blog.csdn.net/z_ryan/article/details/82322418 区别hash bTree
	索引类型:	  操作系统从磁盘读取数据到内存是以磁盘块（block）为基本单位的，位于同一个磁盘块中的数据会被一次性读取出来，而不是需要什么取什么
		顺序向后读取一定长度的数据放入内存。这样做的理论依据是计算机科学中著名的局部性原理： 当一个数据被用到时，其附近的数据也通常会马上被使用。
		页是计算机管理存储器的逻辑块，硬件及操作系统往往将主存和磁盘存储区分割为连续的大小相等的块，每个存储块称为一页（在许多操作系统中，页得大小通常为4k）。
		
		innodb引擎数据存储:  https://www.cnblogs.com/xiaohouye/p/11169098.html
				在InnoDB存储引擎中，也有页的概念，默认每个页的大小为16K，也就是每次读取数据时都是读取4*4k的大小！假设我们现在有一个用户表，我们往里面写数据
		相关:  https://www.cnblogs.com/xqzt/p/4456746.html   这个博主还有其他的财富
		
!优化搜索


-- select VERSION(),CURRENT_USER;
-- SELECT SIN(PI()/4), (4+1)*5;
-- SELECT VERSION(); SELECT NOW();   --你可以在一行上输入多条语句，只需要以一个分号间隔开各语句：

-- 注意，USE，类似QUIT，不需要一个分号。
-- SELECT user(),CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP;  -- 查询当前用户,当前日期 +当前时间 = 时间戳,

-- ----------------------------------------------------------------------------------------------------
-- mysql 
show VARIABLES;  -- 功能强大的查看shell命令

-- -----------------------------------------------------------------------------------------------------

-- information_schema 源数据获取

-- -------------------------------------------------------------------------------------------------------

/* https://www.cnblogs.com/dadonggg/p/8625500.html*/
-- mysqladmin   mysql客户端

show [SESSION | GLOBAL] variables;
SHOW [SESSION | GLOBAL] STATUS;

-- --------------------------------------------------------------------------------------------------------

SHOW ENGINES;  -- 展示当前mysql支持哪个存储引擎
SHOW VARIABLES LIKE 'have%'; -- 检查你感兴趣的存储引擎的变量值：
/*
https://www.cnblogs.com/xiaoboluo768/p/5171425.html  案例
=====================================
200423 17:48:14 INNODB MONITOR OUTPUT
=====================================
   -- #第四行显示的是计算出这一平均值的时间间隔，即自上次输出以来的时间，或者是距上次内部复位的时长
Per second averages calculated from the last 26 seconds
-----------------
BACKGROUND THREAD
-----------------

srv_master_thread loops: 30977173 1_second, 30975685 sleeps, 3090359 10_second, 166112 background, 165988 flush 
#这行显示主循环进行了30977173 1_second次，每秒挂起的操作进行了30975685 sleeps次（说明负载不是很大），10秒一次的活动进行了3090359 10_second次，1秒循环和10秒循环比值符合1：10，backgroup loop进行了166112 background次，flush loop进行了165988 flush次，如果在一台很大压力的mysql上，可能看到每秒运行次数和挂起次数比例小于1很多，这是因为innodb对内部进行了一些优化，
当压力大时间隔时间并不总是等待1秒，因此，不能认为每秒循环和挂起的值总是相等，在某些情况下，可以通过两者之间的差值来比较反映当前数据库的负载压力。

srv_master_thread loops: 15 1_second, 15 sleeps, 1 10_second, 6 background, 6 flush

srv_master_thread log flush and writes: 15
----------
SEMAPHORES  3.如果有高并发的工作负载，你就要关注下接下来的段（SEMAPHORES信号量）,它包含了两种数据：事件计数器以及可选的当前等待线程的列表，如果有性能上的瓶颈，可以使用这些信息来找出瓶颈，不幸的是，想知道怎么使用这些信息还是有一点复杂，下面先给出一些解释：
----------本机
OS WAIT ARRAY INFO: reservation count 4, signal count 4
Mutex spin waits 1, rounds 30, OS waits 1
RW-shared spins 3, rounds 90, OS waits 3
RW-excl spins 0, rounds 0, OS waits 0
Spin rounds per wait: 30.00 mutex, 30.00 RW-shared, 0.00 RW-excl

   --样机
OS WAIT ARRAY INFO: reservation count 68581015, signal count 218437328 
--Thread 140653057947392 has waited at btr0pcur.c line 437 for 0.00 seconds the semaphore:
S-lock on RW-latch at 0x7ff536c7d3c0 created in file buf0buf.c line 916
a writer (thread id 140653057947392) has reserved it in mode  exclusive
number of readers 0, waiters flag 1, lock_word: 0
Last time read locked in file row0sel.c line 3097
Last time write locked in file /usr/local/src/soft/mysql-5.5.24/storage/innobase/buf/buf0buf.c line 3151
--Thread 140653677291264 has waited at btr0pcur.c line 437 for 0.00 seconds the semaphore:
S-lock on RW-latch at 0x7ff53945b240 created in file buf0buf.c line 916
a writer (thread id 140653677291264) has reserved it in mode  exclusive
number of readers 0, waiters flag 1, lock_word: 0
Last time read locked in file row0sel.c line 3097
Last time write locked in file /usr/local/src/soft/mysql-5.5.24/storage/innobase/buf/buf0buf.c line 3151
Mutex spin waits 1157217380, rounds 1783981614, OS waits 10610359
RW-shared spins 103830012, rounds 1982690277, OS waits 52051891
RW-excl spins 43730722, rounds 602114981, OS waits 3495769
Spin rounds per wait: 1.54 mutex, 19.10 RW-shared, 13.77 RW-excl

---样机分析
OS WAIT ARRAY INFO: reservation count 68581015, signal count 218437328  #这行给出了关于操作系统等待数组的信息，它是一个插槽数组，innodb在数组里为信号量保留了一些插槽，操作系统用这些信号量给线程发送信号，使线程可以继续运行，以完成它们等着做的事情，这一行还显示出innodb使用了多少次操作系统的等待：保留统计（reservation count）显示了innodb分配插槽的频度，而信号计数（signal count）衡量的是线程通过数组得到信号的频度，操作系统的等待相对于空转等待（spin wait）要昂贵些。

--Thread 140653057947392 has waited at btr0pcur.c line 437 for 0.00 seconds the semaphore:
S-lock on RW-latch at 0x7ff536c7d3c0 created in file buf0buf.c line 916
a writer (thread id 140653057947392) has reserved it in mode  exclusive
number of readers 0, waiters flag 1, lock_word: 0
Last time read locked in file row0sel.c line 3097
Last time write locked in file /usr/local/src/soft/mysql-5.5.24/storage/innobase/buf/buf0buf.c line 3151
--Thread 140653677291264 has waited at btr0pcur.c line 437 for 0.00 seconds the semaphore:
S-lock on RW-latch at 0x7ff53945b240 created in file buf0buf.c line 916
a writer (thread id 140653677291264) has reserved it in mode  exclusive
number of readers 0, waiters flag 1, lock_word: 0
Last time read locked in file row0sel.c line 3097
Last time write locked in file /usr/local/src/soft/mysql-5.5.24/storage/innobase/buf/buf0buf.c line 3151
    这部分显示的是当前正在等待互斥量的innodb线程，在这里可以看到有两个线程正在等待，每一个都是以--Thread <数字> has waited...开始，这一段内容在正常情况下应该是空的（即查看的时候没有这部分内容），除非服务器运行着高并发的工作负载，促使innodb采取让操作系统等待的措施，除非你对innodb源码熟悉，否则这里看到的最有用的信息就是发生线程等待的代码文件名 /usr/local/src/soft/mysql-5.5.24/storage/innobase/buf/buf0buf.c line 3151。
		
		 在innodb内部哪里才是热点？举例来说，如果看到许多线程都在一个名为buf0buf.c的文件上等待，那就意味着你的系统里存在着
缓冲池竞争，这个输出信息还显示了这些线程等待了多少时间，其中waiters flag显示了有多少个等待着正在等待同一个互斥量。 如果waiters flag为0那就表示没有线程在等待同一个互斥量（此时在waiters flag 0后面可能可以看到wait is ending，表示这个互斥量已经被释放了，但操作系统还没有把线程调度过来运行）。
 你可能想知道innodb真正等待的是什么，innodb使用了互斥量和信号量来保护代码的临界区，如：限定每次只能有一个线程进入临界区，或者是当有活动的读时，就限制写入等。在innodb代码里有很多临界区，在合适的条件下，它们都可能出现在那里，常常能见到的一种情形是：获取缓冲池分页的访问权的时候。
 
 
		
------------
TRANSACTIONS
------------
Trx id counter 1A03
Purge done for trx's n:o < 162A undo n:o < 0
History list length 556
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 0, not started
MySQL thread id 2, OS thread handle 0x62c, query id 80 localhost 127.0.0.1 root
---TRANSACTION 1A02, not started
MySQL thread id 1, OS thread handle 0x2da8, query id 101 localhost 127.0.0.1 root
SHOW ENGINE INNODB STATUS
--------
FILE I/O
--------
I/O thread 0 state: wait Windows aio (insert buffer thread)
I/O thread 1 state: wait Windows aio (log thread)
I/O thread 2 state: wait Windows aio (read thread)
I/O thread 3 state: wait Windows aio (read thread)
I/O thread 4 state: wait Windows aio (read thread)
I/O thread 5 state: wait Windows aio (read thread)
I/O thread 6 state: wait Windows aio (write thread)
I/O thread 7 state: wait Windows aio (write thread)
I/O thread 8 state: wait Windows aio (write thread)
I/O thread 9 state: wait Windows aio (write thread)
Pending normal aio reads: 0 [0, 0, 0, 0] , aio writes: 0 [0, 0, 0, 0] ,
 ibuf aio reads: 0, log i/o's: 0, sync i/o's: 0
Pending flushes (fsync) log: 0; buffer pool: 0
566 OS file reads, 7 OS file writes, 7 OS fsyncs
0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
 insert 0, delete mark 0, delete 0
discarded operations:
 insert 0, delete mark 0, delete 0
Hash table size 97649, node heap has 0 buffer(s)
0.00 hash searches/s, 0.00 non-hash searches/s
---
LOG
---
Log sequence number 47605798
Log flushed up to   47605798
Last checkpoint at  47605798
0 pending log writes, 0 pending chkp writes
10 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total memory allocated 50446336; in additional pool allocated 0
Dictionary memory allocated 41859
Buffer pool size   3008
Free buffers       2453
Database pages     555
Old database pages 224
Modified db pages  0
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 0, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 555, created 0, written 1
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 555, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
ROW OPERATIONS
--------------
0 queries inside InnoDB, 0 queries in queue
1 read views open inside InnoDB
Main thread id 13348, state: waiting for server activity
Number of rows inserted 0, updated 0, deleted 0, read 11713
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
----------------------------
END OF INNODB MONITOR OUTPUT
============================
*/
SHOW ENGINE INNODB STATUS;   -- 信息很多





-- ---------------------------------------------------------------------------------------------------------

/*
查看当前所有连接session状态
*/
show PROCESSLIST; 

-- ----------------------------------------------------------------------------------------------------------

/* 
slow_query_log 是否启用慢日志参数
slow_query_log_file MySQL数据库（5.6及以上版本）慢查询日志存储路径。
                    可以不设置该参数，系统则会默认给一个缺省的文件 HOST_NAME-slow.log
long_query_time :慢查询的阈值

https://www.cnblogs.com/saneri/p/6656161.html  慢日志总结
*/
SHOW VARIABLES LIKE 'slow_query_log'; 
SHOW VARIABLES LIKE 'slow_query_log_file'; 
SHOW VARIABLES LIKE 'long_query_time'; 
/*
没有使用索引的语句  未使用索引的查询也被记录到慢查询日志中（可选项）。
*/
SHOW VARIABLES LIKE 'log_queries_not_using_indexes'; 
/*
开启慢日志,立即生效，重启失效   mysqldumpslow工具分析慢日志!--   mysqldumpslow --help  
https://www.cnblogs.com/hjqjk/p/Mysqlslowlog.html   慢日志分析

windows my.ini文件
[mysqld]  插曲  mysql启动不了  mysqld --console 服务器
#开启慢查询
slow_query_log = ON
#log-slow-queries:代表MYSQL慢查询的日志存储目录,此目录文件一定要有写权限；
log-slow-queries="C:/Program Files (x86)/MySQL/MySQL Server 5.0/log/mysql-slow.log"
#最长执行时间 (查询的最长时间，超过了这个时间则记录到日志中) .
long_query_time = 1
#没有使用到索引的查询也将被记录在日志中
log-queries-not-using-indexes = ON
*/
set global slow_query_log=ON;
-- 设置慢日志文件,可以不用设置,默认有一个
set global slow_query_log_file='c:/mysql-slow.log';


--  --------------------------------------------------------------------------------------

/*
	https://blog.csdn.net/sinat_22594643/article/details/87971916
	查看表的索引: 结合项目经验案例: 普通索引与唯一索引的选择 
	全文索引: 关键字搜索!
	
		Non_unique:  如果该列索引中不包括重复的值则为0 否则为1      ShopId需要唯一,可以使用业务处理!
				shopinfos	0	PRIMARY						1	Id					A	0					BTREE		
				shopinfos	1	IX_ShopId					1	ShopId			A	0			YES	BTREE		
				shopinfos	1	Mobile_CreateTime	1	Mobile			A	0			YES	BTREE		
				shopinfos	1	Mobile_CreateTime	2	CreateTime	A	0					BTREE	
		Seq_in_index : 索引中序列的序列号,从1开始,如果是组合索引  那么按照字段在建立索引时的顺序排列!
		Collation : 列以什么方式存储在索引中, 在MySQL中，有值‘A’（升序）或NULL（无分序）
		Cardinality : 索引中唯一值的数目的估计值,  通过运行 ANALYZE TABLE or myisamchk -a 来更新,
									基数根据被存储为整数的统计数据来计数,所以对于小表该值没必要太过于精确,
									而对于大数据量的表来说,改值越大当进行联合时，MySQL使用该索引的机 会就越大。
		Sub_part: 索引的长度,如果是部分被编入索引 则该值表示索引的长度 ,如果是整列被编入索引则为null,
							例如name_Index和school_Index 两个索引,比较一下上面两个索引创建时候的区别
		Packed :指示关键字如何被压缩。如果没有被压缩，则为NULL
		Null:如果该列的值有NULL,则是YES 否则为NO..
		Index_type: 所用索引方法（BTREE, FULLTEXT, HASH, RTREE）
		Commnet : 关于在其列中没有描述的索引的信息
		Index_comment: 为索引创建时提供了一个注释属性的索引的任何评论
*/
show index from shopinfos;  
/**
	--  SHOW INDEX FROM tbl_name 查看表的索引
	--  强制MySQL使用或忽视possible_keys列中的索引，在查询中使用FORCE INDEX、USE INDEX或者IGNORE INDEX
	
	-- select_type 类型
			-- SIMPLE    简单查询(不使用union 或者子查询)
			-- primary   最外面的SELECT
			-- UNION     UNION中的第二个或后面的SELECT语句
			-- DEPENDENT UNION   UNION中的第二个或后面的SELECT语句，取决于外面的查询
			-- SUBQUERY  子查询中的第一个SELECT
			-- DEPENDENT SUBQUERY  子查询中的第一个SELECT，取决于外面的查询
			-- DERIVED   导出表的SELECT(FROM子句的子查询)
	-- table 所查询的表
			-- 所查询的表
	-- type 联接类型
			-- system  表仅有一行(=系统表)。这是const联接类型的一个特例。
			-- const   最多有一个匹配行，它将在查询开始时被读取,因为仅有一行，在这行的列值可被优化器剩余部分认为是常数。const表很快，因为它们只读取一次！
						--  用常数值比较PRIMARY KEY或UNIQUE索引的所有部分时
			-- eq_ref  对于每个来自于前面的表的行组合，从该表中读取一行。这可能是最好的联接类型，
						-- eq_ref可以用于使用= 操作符比较的带索引的列。
			-- ref   对于每个来自于前面的表的行组合，所有有匹配索引值的行将从这张表中读取。如果联接只使用键的最左边的前缀，或如果键不是UNIQUE或PRIMARY 					  KEY（换句话说，如果联接不能基于关键字选择单个行的话），则使用ref。如果使用的键仅仅匹配少量行，该联接类型是不错的。
						-- ref可以用于使用=或<=>操作符的带索引的列。
			-- ref_or_null  该联接类型如同ref    在解决子查询中经常使用该联接类型的优化  WHERE key_column=expr OR key_column IS NULL
			--  index_merge  该联接类型表示使用了索引合并优化方法,-- key 列包含了使用的索引的清单  -- key_len包含了使用的索引的最长的关键元素
			--   range  只检索给定范围的行，使用一个索引来选择行,key列显示使用了哪个索引
			-- index  该联接类型与ALL相同，除了只有索引树被扫描。这通常比ALL快，因为索引文件通常比数据文件小。
			-- Extra 额外信息
					-- Distinct   MySQL发现第1个匹配行后，停止为当前的行组合搜索更多的行。  除去作用有时候
					-- 略
*/
EXPLAIN select * from authrecords;   -- https://www.mysqlzh.com/doc/66/292.html

全文检索: elasticsearch 倒排索引
		
		
	


					
-- ----------------------------------------------------------------------------------------------------------------				
-- 应急调优
#  1. show processlist；
#	 2. explain 
#	 3. 通过执行计划判断，索引问题（有没有、合不合理）或者语句本身问题；
#	 4. show status like '%lock%'; # 查询锁状态  
#	kill SESSION_ID; # 杀掉有问题的session。
	
	
	
	
	
	
	
