
#res=$( curl -w %{http_code} -s --output /dev/null http://192.168.0.3:6379)
#echo "${res}"
function runJar(){
	COUNT=$(ps -ef |grep -iw $1 |grep -v "grep" |wc -l)
	echo $COUNT
	if [ $COUNT -eq 0 ]; then
        echo "RUN ${2}"
        # java -jar $1 >> $3 2>&1 &
        java -jar $1 2>&1 |tee $3 
        echo "RUN ${2} OVER"
	else
        echo "${2} is RUN"
	fi
	
}



LOG1_FILE=$(pwd)/logs/spider2oracle.log
APP1_NAME=/Users/zxl/ideaprojects/zxlspider/out/artifacts/spider2oracle/zxlspider.jar
APP1_SHOWNAME=spider2oracle

if [ ! -e "$APP1_NAME" ]; then
 echo "${APP1_NAME} 不存在或没有可执行权限"
 exit 1
fi

#刷新/创建日志文件
 touch "$LOG1_FILE"

#spider部分
sh startdocker.sh
#启动容器
sh startcontainer.sh oracle11g
#阻塞检查
echo "检查oracle端口"
while ! nc -z 127.0.0.1 1521; 
  do printf ".";
  sleep 1
done
sleep 20
#启动jar
runJar $APP1_NAME $APP1_SHOWNAME $LOG1_FILE




LOG2_FILE=$(pwd)/logs/put2redis.log
APP2_NAME=/Users/zxl/ideaprojects/zxlspider/out/artifacts/put2redis/zxlspider.jar
APP2_SHOWNAME=put2redis
if [ ! -e "$APP2_NAME" ]; then
 echo "${APP2_NAME} 不存在或没有可执行权限"
 exit 1
fi
#刷新/创建日志文件
 touch "$LOG2_FILE"

#putredis部分
sh startdocker.sh
#启动容器
sh startcontainer.sh oracle11g
sh startcontainer.sh redis
#阻塞检查
echo "检查redis端口"
while ! nc -z 127.0.0.1 6379; 
  do printf ".";
  sleep 1
done
echo "检查oracle端口"
while ! nc -z 127.0.0.1 1521; 
  do printf ".";
  sleep 1
done
#启动jar
runJar $APP2_NAME $APP2_SHOWNAME $LOG2_FILE





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
sh startcontainer.sh compassionate_chaplygin
sh startcontainer.sh logstash
#阻塞检查
echo "检查es的Http协议"
res=$( curl -w %{http_code} -s --output /dev/null http://192.168.0.3:9200)
while [[ "$res" -ne 200 ]]; 
  do printf ".";
  sleep 1
  res=$( curl -w %{http_code} -s --output /dev/null http://192.168.0.3:9200)
done
#todo: 改为jar校验完成状态
sleep 120
#启动jar 
# 不带参数 增量方式
runJar $APP3_NAME $APP3_SHOWNAME $LOG3_FILE


docker stop  compassionate_chaplygin
docker stop  logstash
docker stop  oracle11g
# docker stop  redis


echo "ok"
