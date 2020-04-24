GET /_cluster/health

{
   "cluster_name": "DAZE-ESDATA",
   "status": "yellow",
   "timed_out": false,
   "number_of_nodes": 1,
   "number_of_data_nodes": 1,
   "active_primary_shards": 1724,
   "active_shards": 1724,
   "relocating_shards": 0,
   "initializing_shards": 0,
   "unassigned_shards": 483,      //没有被分配到任何节点的副本数。
   "delayed_unassigned_shards": 0,
   "number_of_pending_tasks": 0,
   "number_of_in_flight_fetch": 0,
   "task_max_waiting_in_queue_millis": 0,
   "active_shards_percent_as_number": 78.11508835523335
}
status :集群总体健康状况

索引:
文档和索引数据 保存到分片中!

---------------------------------------------------------------------------

分片: 主片与副片
	一个分片是主分片,或副本分片! 主分片界定索引能够保存最大数据量
PUT /blogs
{
   "settings" : {
      "number_of_shards" : 3,
      "number_of_replicas" : 1
   }
}

----------------------------------------------------------------------------

添加故障转移

集群中只有一个节点运行会出现单点故障
(第二节点, 同一台电脑,安装一个共享目录,只要启动的节点名称clister.name 一样,会自动加入集群中!)
(如果不是同一个机器, 你需要配置一个可连接到的单播主机列表。 详细信息请查看最好使用单播代替组播)

----------------------------------------------------------------------------

水平扩容: https://www.elastic.co/guide/cn/elasticsearch/guide/current/_scale_horizontally.html
	拥有三个节点,为了分散负载,可以对分片进行重新分配,
	每个节点的硬件资源（CPU, RAM, I/O）将被更少的分片所共享，每个分片的性能将会得到提升。
	
PUT /blogs/_settings
{
   "number_of_replicas" : 2
}
把副本数从默认的 1 增加到 2 ：

--------------------------------------------------------------------------------

索引文档(文档源数据,包括 _index,_type,_id)
		
如果文档需要自然id,需要自己提供
PUT /{index}/{type}/{id}
{
  "field": "value",
  ...
}

每个文档都有一个版本号,当每次对文档进行修改时（包括删除）， _version 的值会递增。 在 处理冲突 中，
我们讨论了怎样使用 _version 号码确保你的应用程序中的一部分修改不会覆盖另一部分所做的修改。

GET /website/blog/123?pretty
/*
在请求的查询串参数中加上 pretty 参数，正如前面的例子中看到的，这将会调用 Elasticsearch 的 pretty-print 功能，
该功能 使得 JSON 响应体更加可读。但是， _source 字段不能被格式化打印出来。相反，我们得到的 _source 字段中的 JSON 串，
刚好是和我们传给它的一样。
*/
{	
  "_index" :   "website",
  "_type" :    "blog",
  "_id" :      "123",
  "_version" : 1,
  "found" :    true,   -- 文档被找到,如果找不到,回事false,http返回码是404 not found
  "_source" :  {
      "title": "My first blog entry",
      "text":  "Just trying this out...",
      "date":  "2014/01/01"
  }
}

返回文档的一部分
GET /website/blog/123?_source=title,text

/*只返回sourse*/
GET /website/blog/123/_source

----------------------------------------------------------------------------

检查文档是否存在 (不关心内容)

curl -i -XHEAD http://localhost:9200/website/blog/123
curl -i -HEAD http://localhost:9200/website/blog/123

-----------------------------------------------------------------------------------

冲突解决(秒杀案例)  *****
		乐观并发控制
--------------------------------------------------------------------------------

更新整个文档   _version增加
PUT /website/blog/123
{
  "title": "My first blog entry",
  "text":  "I am starting to get the hang of this...",
  "date":  "2014/01/02"
}

{
  "_index" :   "website",
  "_type" :    "blog",
  "_id" :      "123",
  "_version" : 2,
  "created":   false 
}


更新部分文档  
	  接收文档的一部分作为 doc 的参数， 它只是与现有的文档进行合并。对象被合并到一起，覆盖现有的字段，增加新的字段。
POST /website/blog/1/_update  
{
   "doc" : {
      "tags" : [ "testing" ],
      "views": 0
   }
}

-------------------------------------------------------------------------
	
	GET /_mget   -- 获取多个
{
   "docs" : [
      {
         "_index" : "dzxiaodian",
         "_type" :  "offer",
         "_id" :    "128666abdab265a0"
      },
      {
         "_index" : "dzxiaodian",
         "_type" :  "customerstatistics",
         "_id" :    "c584726111b241a58e91dda749fb1ed2"
        "_source": ""
      }
   ]
}
/*
{
   "docs": [
      {
         "_index": "dzxiaodian",
         "_type": "offer",
         "_id": "128666abdab265a0",
         "_version": 1,
         "found": true,
         "_source": {
            "CategoryId": 127386001,
            "ShareImg": "xiaodian/shops/ueeiuq/offers/128666abdab265a0.png",
            "ModifyTime": "2018-12-19T20:03:22",
            "Classify": [
               "0"
            ],
            "SkuInfo": [
               {
                  "IsHidden": false,
                  "AttributeValue": "白色2均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "白色2",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 767,
                  "SkuPrice": 83.49,
                  "SpecId": "a61ca82021ddfb1c287c87b3a6256b35",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/808/689/9606986808_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985502,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "藕紫色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "藕紫色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 678,
                  "SkuPrice": 83.49,
                  "SpecId": "be120852b5496e3af03e4a2a239e856f",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/494/766/9560667494_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985503,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "黄 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "黄 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 854,
                  "SkuPrice": 83.49,
                  "SpecId": "15d5f1e1cfdbab9a6c6bc52bdc5247b1",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/613/400/9607004316_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985504,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "黑 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "黑 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 874,
                  "SkuPrice": 83.49,
                  "SpecId": "1b84660c81733cb3f8cd80b321a026b3",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/076/331/9585133670_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985505,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "蓝色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "蓝色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 821,
                  "SkuPrice": 83.49,
                  "SpecId": "7729bba36b2bcd81c05048dbd670e082",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/266/631/9585136662_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985506,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "浅咖2均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "浅咖2",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 893,
                  "SkuPrice": 83.49,
                  "SpecId": "6530623aea4e45c9d51b9f313d37cae0",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/861/961/9585169168_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985507,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "黄色2均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "黄色2",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 930,
                  "SkuPrice": 83.49,
                  "SpecId": "fcdb1f9ec7d448eb1691ab41084cf933",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/197/299/9606992791_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985508,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "白色3均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "白色3",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 932,
                  "SkuPrice": 83.49,
                  "SpecId": "e26071f769c9705a9d8e9446af1ac63a",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/434/841/9585148434_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985509,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "浅咖均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "浅咖",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 752,
                  "SkuPrice": 83.49,
                  "SpecId": "77cb918202401aa2da470132d1f78336",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/972/361/9585163279_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985510,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "蓝 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "蓝 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 687,
                  "SkuPrice": 83.49,
                  "SpecId": "8635177b0f31aaab56adb410c22dfb12",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/271/571/9585175172_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985511,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "灰 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "灰 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 845,
                  "SkuPrice": 83.49,
                  "SpecId": "085befd9af5ee69b015832619d52892a",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/332/271/9585172233_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985512,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "白 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "白 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 851,
                  "SkuPrice": 83.49,
                  "SpecId": "97663810ce33aceda2290708649e1408",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/414/976/9560679414_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985513,
                  "DistributorIncome": 6.9
               },
               {
                  "IsHidden": false,
                  "AttributeValue": "绿 色均码（80-128斤）",
                  "RetailPrice": 76,
                  "DistributorSkuPrice": 75.9,
                  "SkuCost": 75.9,
                  "Attributes": [
                     {
                        "AttributeValue": "绿 色",
                        "AttributeId": 3216,
                        "AttrbiuteName": "颜色"
                     },
                     {
                        "AttributeValue": "均码（80-128斤）",
                        "AttributeId": 450,
                        "AttrbiuteName": "尺码"
                     }
                  ],
                  "AmountOnSale": 941,
                  "SkuPrice": 83.49,
                  "SpecId": "378e493bda49ccc85282bc25c9427ea4",
                  "SkuImageUrl": "http://cbu01.alicdn.com/img/ibank/2018/431/181/9585181134_50126886.jpg",
                  "SkuIncome": 7.59,
                  "SkuId": 3878418985514,
                  "DistributorIncome": 6.9
               }
            ],
            "IsActive": false,
            "Income": 7.59,
            "FreightTemplateId": 10585693,
            "DistributorOfferKey": "7b4916d81c80f9ba",
            "DistributorShopId": "U3i6rm",
            "Cost": 75.9,
            "OpenId": "oUcw80_DqDVag3AdoQhJpISLFQa0",
            "OfferType": 1,
            "OfferId": 581157263220,
            "EasyDetail": "【活动】：ins超火 时尚刺绣毛衣 包芯纱！！\n【款号】；10301\n【品名】：ins时尚小香风针织毛衣 面料炒鸡好！\n",
            "SupplierLoginId": "美丽说衣阁1688",
            "ImgList": [
               "http://cbu01.alicdn.com/img/ibank/2018/655/976/9560679556_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/672/271/9585172276_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/974/841/9585148479_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/358/721/9585127853_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/638/689/9606986836_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/125/766/9560667521_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/033/400/9607004330_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/686/631/9585136686_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/491/610/9607016194_50126886.jpg"
            ],
            "ShopId": "ueeiuq",
            "ShowDetailText": false,
            "DistributorIncome": 0,
            "Status": 2,
            "QrCodeImgUrl": null,
            "SaledCount": 0,
            "AmountOnSale": 10825,
            "AddTime": "2018-11-29T15:11:36",
            "ShippingFee": 0,
            "Subject": "10301 时尚针织毛衣",
            "DistributorUnitPrice": 75.9,
            "Retailprice": 0,
            "DetailImgList": [
               "https://cbu01.alicdn.com/img/ibank/2018/358/721/9585127853_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/638/689/9606986836_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/125/766/9560667521_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/033/400/9607004330_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/686/631/9585136686_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/491/610/9607016194_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/591/961/9585169195_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/018/299/9606992810_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/795/100/9607001597_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/672/271/9585172276_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/444/976/9560679444_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/071/181/9585181170_50126886.jpg",
               "https://cbu01.alicdn.com/img/ibank/2018/216/100/9607001612_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/808/689/9606986808_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/494/766/9560667494_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/613/400/9607004316_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/076/331/9585133670_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/266/631/9585136662_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/861/961/9585169168_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/197/299/9606992791_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/434/841/9585148434_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/972/361/9585163279_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/271/571/9585175172_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/332/271/9585172233_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/414/976/9560679414_50126886.jpg",
               "http://cbu01.alicdn.com/img/ibank/2018/431/181/9585181134_50126886.jpg"
            ],
            "UnitPrice": 83.49,
            "IsSkuOffer": true,
            "SupplierAliId": "b2b-306481565223653",
            "IsFreeShipping": true,
            "Key": "128666abdab265a0",
            "Detail": "【活动】：ins超火 时尚刺绣毛衣 包芯纱！！\n【款号】；10301\n【品名】：ins时尚小香风针织毛衣 面料炒鸡好！\n【面料】：加厚包芯纱\n【尺寸】：均码 80-128斤可穿\n------------------------------------\n【售后】：7天无理由退换\n【快递】：默认发韵达快递 其他快递补运费\n【提示】：此款为新品 排单发货 7天内发完 不接急单",
            "AliId": "b2b-2613179621fe405"
         }
      },
      {
         "_index": "dzxiaodian",
         "_type": "customerstatistics",
         "_id": "c584726111b241a58e91dda749fb1ed2",
         "_version": 1,
         "found": true,
         "_source": {
            "CreateTime": "2019-09-20T14:49:15",
            "Business": "shopid:EfmAfa|",
            "ShopId": "EfmAfa",
            "CustomerId": 52,
            "RealIp": "110.80.153.188, 61.151.178.172"
         }
      }
   ]
}
*/

------------------------------------------------------------------------------
GET /website/blog/_mget
{
   "docs" : [
      { "_id" : 2 },
      { "_type" : "pageviews", "_id" :   1 }
   ]
}


GET /website/blog/_mget  -- 获取多个
{
   "ids" : [ "2", "1" ]
}

---------------------------------------------------------------------------------

POST /_bulk     -- 可能已经过期了
{ "delete": { "_index": "website", "_type": "blog", "_id": "123" }} 
{ "create": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title":    "My first blog post" }
{ "index":  { "_index": "website", "_type": "blog" }}
{ "title":    "My second blog post" }
{ "update": { "_index": "website", "_type": "blog", "_id": "123", "_retry_on_conflict" : 3} }
{ "doc" : {"title" : "My updated blog post"} }








