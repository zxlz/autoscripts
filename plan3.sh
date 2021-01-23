function runJar(){
	COUNT=$(ps -ef |grep -iw $1 |grep -v "grep" |wc -l)
	echo $COUNT
	if [ $COUNT -eq 0 ]; then
        echo "RUN ${2}"
        # java -jar $1 >> $3 2>&1 &
        java -jar $1 $4 2>&1 |tee $3 
        echo "RUN ${2} OVER"
	else
        echo "${2} is RUN"
	fi
	
}
# $1 jar包参数
LOG3_FILE=$(pwd)/logs/putes2redis.log
APP3_NAME=/Users/zxl/ideaprojects/zxlspider/out/artifacts/putes2redis/zxlspider.jar
APP3_SHOWNAME=putes2redis
if [ ! -e "$APP3_NAME" ]; then
 echo "${APP3_NAME} 不存在或没有可执行权限"
 exit 1
fi
#刷新/创建日志文件
 touch "$LOG3_FILE"


#logstah部分
sh startdocker.sh
#启动容器
sh startcontainer.sh redis
sh startcontainer.sh esdata4
sh startcontainer.sh oracle11g
#阻塞检查
echo "检查es的Http协议"
res=$( curl -w %{http_code} -s --output /dev/null http://192.168.0.3:9200)
while [[ "$res" -ne 200 ]]; 
  do printf ".";
  sleep 1
  res=$( curl -w %{http_code} -s --output /dev/null http://192.168.0.3:9200)
done


# echo "删除原map"
# res=0
# try=3
# while [[ "$res" -ne 200 ]]; 
#   do 
#   if [ ${try} -eq 0 ]; then     
#             echo 'warn:删除原map失败'
#             break
#   fi
#   res=$( curl -w %{http_code} -s --output /dev/null -XDELETE http://192.168.0.3:9200/data4/ );
#   printf ".";
#   sleep 1;
#   try=$[${try}-1]
# done

# echo "重建map"
# res=0
# try=3
# while [[ "$res" -ne 200 ]]; 
#   do 
#   if [ ${try} -eq 0 ]; then     
#             echo 'warn:重建原map失败'
#             break
#   fi
#   res=$(curl -w %{http_code} -s --output /dev/null -XPUT http://127.0.0.1:9200/data4 -H 'Content-Type: application/json' -d '{  "mappings": {    "properties": {      "brief": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true        },      "content":{        "type": "text",        "analyzer": "ik_smart",        "fielddata": true      },      "title": {          "type": "text",          "analyzer": "ik_smart",          "fielddata": true      }    }  }}');
#   printf ".";
#   sleep 1;
#   try=$[${try}-1]
# done

sh startcontainer.sh logstash


#启动jar 
# 内部会阻塞校验数据准备完成。 
# 不带参数：增量方式 带参数：all全部刷新
runJar $APP3_NAME $APP3_SHOWNAME $LOG3_FILE $1


echo "ok"
