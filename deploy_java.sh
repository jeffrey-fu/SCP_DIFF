#!/bin/bash

# 变量
Port=9000     # 端口
Address=9001  # 断点端口
Env=dev       # 启动环境
#########################

echo "*** 停止服务 ***"

# 杀进程
kill -9 $(netstat -nlp | grep "${Port}" | awk '{print $7}' | awk -F"/" '{print $1}')

sleep 20

# 确定进程是否被杀
Java=$(netstat -lanput | grep "${Address}" | awk '{print $7}' | awk -F'/' '{print $2}')
if [ "${Java}" == 'java' ];then
  echo "检测到进程还存在，再杀一次"
  #再杀一次
  kill -9 $(netstat -nlp | grep "${Address}" | awk '{print $7}' | awk -F"/" '{print $1}')
  sleep 20
fi

echo "*** 开始启动服务 ***"

# 起服务
java -Xdebug -Xrunjdwp:transport=dt_socket,address=${Address},server=y,suspend=n -jar web-0.0.1-exec.jar --spring.profiles.active=${Env} > log.file 2>&1 &

# 打印日志
tail -f `pwd`/log.file &

# 等待160秒(服务启动成功)
sleep 160

# 杀tail进程
kill -9 $(ps -ef | grep "tail -f `pwd`/log.file" | awk 'NR==1 {print $2}')

exit
