

res=$( curl -w %{http_code} -s --output /dev/null -XDELETE http://192.168.0.3:9200/data4/ )
echo "$res"

res=$( curl -w %{http_code} -s --output /dev/null -XDELETE http://192.168.0.3:9200/data4/ )
echo "$res"
res1=$(curl -w %{http_code} -s --output /dev/null -XPUT http://127.0.0.1:9200/data4 -H 'Content-Type: application/json' -d '{  "mappings": {    "properties": {      "brief": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true        },      "content":{        "type": "text",        "analyzer": "ik_smart",        "fielddata": true      },      "title": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true      }    }  }}')
echo "$res1"
res1=$(curl -w %{http_code} -s --output /dev/null -XPUT http://127.0.0.1:9200/data4 -H 'Content-Type: application/json' -d '{  "mappings": {    "properties": {      "brief": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true        },      "content":{        "type": "text",        "analyzer": "ik_smart",        "fielddata": true      },      "title": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true      }    }  }}')
echo "$res1"