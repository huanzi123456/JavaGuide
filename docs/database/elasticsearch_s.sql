GET dzxd_common_order/order/_mapping

/*
过滤器的使用:与范围查询的区别?
match  查找独立单词
match_phrase 精确匹配一些列单词或短语

*/

GET /megacorp/employee/_search
{
    "query" : {
        "bool": {
            "must": {
                "match" : {
                    "last_name" : "smith" 
                }
            },
            "filter": {
                "range" : {
                    "age" : { "gt" : 30 } 
                }
            }
        }
    }
}

/*
hightlight 高亮
*/
GET /dzxd_article/article/_search
{
  "from" : 0,
  "size" : 10,
  "query" : {
    "bool" : {
      "must" : [
        {
          "wildcard" : {
            "title" : {
              "wildcard" : "*健康*",
              "boost" : 1.0
            }
          }
        },
        {
          "term" : {
            "status" : {
              "value" : 1,
              "boost" : 1.0
            }
          }
        }
      ],
      "must_not" : [
        {
          "term" : {
            "isDelete" : {
              "value" : -1,
              "boost" : 1.0
            }
          }
        },
        {
          "exists" : {
            "field" : "type",
            "boost" : 1.0
          }
        }
      ],
      "disable_coord" : false,
      "adjust_pure_negative" : true,
      "boost" : 1.0
    }
  },
    "highlight": {
        "fields" : {
            "title" : {}
        }
    },
  "sort" : [
    {
      "browseNumF" : {
        "order" : "desc"
      }
    }
  ]
}


get dzxd_weixin/category/_mapping


PUT dzxd_weixin/category/_mapping
{
    "properties":{
        "type":{
            "type":"integer"
        }
    } 
}

get /dzxiaodian/customorder/_search
{
    "query": {
        "bool": {
            "must": [
               {"range": {
                  "CreateTime": {
                     "gte": "2020-02-01T00:00:00",
                     "lte": "2020-02-29T23:59:59"
                  }
               }}
            ]
        }
    },
    "size": 20
}

/*
只取部分数据
*/
GET /dzxiaodian/extractrecord/_search
{
  "_source": {
        "includes": [ "ShopId" ]
    },
   "query": {
        "range": {
            "ExtractTime": {
                "gte": "2020-04-01T00:00:00",
                "lte": "2020-04-05T23:59:59"
            }
        }
    },
    "size": 2000
}


POST /dzxiaodian/customerorder/_search
{
    "_source": {
        "includes": [ "ShopId" ]
    },
    "query": {
      "bool": {
          "must": [
             {"range": {
              "CreateTime": {
                 "gte": "2020-04-01T00:00:00",
                 "lt": "2020-04-13T23:59:59"
              }
           }}
          ],
          "must": [
             {"term": {
                "OrderStatus": {
                   "value": "4"
                }}}]
            }
        },
        "size": 2000
}


---------------------------------------------------------------------
/*
aggs:terms 相当于 group by  结果为统计的字段分类  加文档统计
聚合加上query可以搜索感兴趣的 信息
*/
POST /dzxiaodian/customerorder/_search
{   
    
    "query": {
      "bool": {
          "must": [
             {"range": {
              "CreateTime": {
                 "gte": "2020-04-01T00:00:00",
                 "lt": "2020-04-30T23:59:59"
              }
           }}
          ],
          "must": [
             {"term": {
                "OrderStatus": {
                   "value": "4"
                }}}]
            }
        },
   "size": 0,
      "aggregations": {
          "group_by_ShopId": {
            "terms": { 
                "field": "ShopId" ,
                "size": 100
            },
            "aggs": {
                "total_price": {
                    "sum": { "field": "TotalAmount" }
                    }
                }
            }
            
        }
        
  }
}

聚合分级汇总
GET /megacorp/employee/_search
{
    "aggs" : {
        "all_interests" : {
            "terms" : { "field" : "interests" },
            "aggs" : {
                "avg_age" : {
                    "avg" : { "field" : "age" }
                }
            }
        }
    }
}
特定兴趣爱好员工的平均年龄
{"buckets": [
        {
           "key": "music",
           "doc_count": 2,
           "avg_age": {
              "value": 28.5
           }
        },
        {
           "key": "forestry",
           "doc_count": 1,
           "avg_age": {
              "value": 35
           }
        },
        {
           "key": "sports",
           "doc_count": 1,
           "avg_age": {
              "value": 25
           }
        }
     ]
}
-------------------------------------------------------------------------


POST /dzxiaodian/customerorder/_search
{
    "query": {
      "bool": {
          "must": [
             {"range": {
              "CreateTime": {
                 "gte": "2020-04-01T00:00:00",
                 "lt": "2020-04-13T23:59:59"
              }
           }}
          ],
          "must": [
             {"term": {
                "OrderStatus": {
                   "value": "4"
                }}}]
            }
        },
   "size": 2000,
      "aggregations": {
        "TotalAmountSum": {
        "term": {
            "field": "TotalAmount"
      }
    }
  }
}

POST /dzxiaodian/customerorder/_search
{
    "query": {
      "bool": {
          "must": [
             {"range": {
              "CreateTime": {
                 "gte": "2020-04-01T00:00:00",
                 "lte": "2020-04-13T23:59:59"
              }
           }}
          ],
          "must": [
             {"term": {
                "OrderStatus": {
                   "value": "4"
                }}}]
            }
        },
   "size": 2000
    
}


