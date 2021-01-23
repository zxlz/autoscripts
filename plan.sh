function runJar(){
	COUNT=$(ps -ef |grep -iw $1 |grep -v "grep" |wc -l)
	echo $COUNT
	if [ $COUNT -eq 0 ]; then
        echo "RUN ${2}"
        #后台运行
        # java -jar $1 >> $3 2>&1 &
        #前台运行
        java -jar $1 $4 2>&1 |tee $3 
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
#应用内会阻塞等待oracle启动
#  sleep 60
#启动jar。 参数：500-100000数字 
runJar $APP1_NAME $APP1_SHOWNAME $LOG1_FILE 10000




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



#数据给es统计，再抽取结果推给redis 参数：all(全量) 默认增量
sh plan3.sh all


docker stop  esdata4
docker stop  logstash
docker stop  oracle11g
# docker stop  redis


echo "ok"
