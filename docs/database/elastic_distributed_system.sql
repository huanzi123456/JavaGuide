elastic_distributed_system
分布式文档存储

			https://www.elastic.co/guide/cn/elasticsearch/guide/current/distrib-write.html


---------------------------------------------------------------------------------------------
多索引,多类型

/_search
在所有的索引中搜索所有的类型
/gb/_search
在 gb 索引中搜索所有的类型
/gb,us/_search
在 gb 和 us 索引中搜索所有的文档
/g*,u*/_search
在任何以 g 或者 u 开头的索引中搜索所有的类型
/gb/user/_search
在 gb 索引中搜索 user 类型
/gb,us/user,tweet/_search
在 gb 和 us 索引中搜索 user 和 tweet 类型
/_all/user,tweet/_search
在所有的索引中搜索 user 和 tweet 类型


------------------------------------------------------------------------------
查询结果分页

GET /_search?size=5
GET /_search?size=5&from=5
GET /_search?size=5&from=10

-------------------------------------------------------------------------------
  es查询结果不要超过1000个
	
理解为什么深度分页是有问题的，我们可以假设在一个有 5 个主分片的索引中搜索。 当我们请求结果的第一页（结果从 1 到 10 ），每一个分片产生前 10 的结果，并且返回给 协调节点 ，协调节点对 50 个结果排序得到全部结果的前 10 个。

现在假设我们请求第 1000 页—​结果从 10001 到 10010 。所有都以相同的方式工作除了每个分片不得不产生前10010个结果以外。 然后协调节点对全部 50050 个结果排序最后丢弃掉这些结果中的 50040 个结果。

可以看到，在分布式系统中，对结果排序的成本随分页的深度成指数上升。这就是 web 搜索引擎对任何查询都不要返回超过 1000 个结果的原因。

-----------------------------------------------------------------------------------

 mapping 映射
 
 结果不同               _all 字段是 string        
GET /_search?q=2014              # 12 results        all结果
GET /_search?q=2014-09-15        # 12 results !      all结果
GET /_search?q=date:2014-09-15   # 1  result 	       date
GET /_search?q=date:2014         # 0  results !

查看映射
GET /gb/_mapping/tweet
{
   "gb": {
      "mappings": {
         "tweet": {
            "properties": {
               "date": {     //es自动产生的
                  "type": "date",
                  "format": "strict_date_optional_time||epoch_millis"   
               },
               "name": {
                  "type": "string"
               },
               "tweet": {
                  "type": "string"
               },
               "user_id": {
                  "type": "long"
               }
            }
         }
      }
   }
}

-------------------------------------------------------------------------------------

分词与分析器



--------------

暂停请求体查询



