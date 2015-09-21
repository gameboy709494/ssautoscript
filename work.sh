#
#  Copyright (R) gameboy709494
#  请参阅https://github.com/gameboy709494/ssautoscript
#  
#


#!/bin/bash

if [ $# == "0" ]
then
  echo 你是不是忘了加参数了？？
  exit
fi

cmd=$1

start () {

  grep -v ^# list.txt | while read line
  do
  
  title=$(echo $line |  cut -d " " -f 1)
  port=$(echo $line |  cut -d " " -f 2)
  passwd=$(echo $line |  cut -d " " -f 3)
  
  lsof -i:${port} > /dev/null
  
  if [ $? == "0"  ]
  then
    echo 服务器端口${port}已被占用，跳过任务${title}。
    continue
  fi
  
  pid=$(cat ${title}.pid 2>/dev/null)
  ps -ax | awk '{ print $1 }' | grep -e "^${pid}$" > /dev/null
  
  if [ $? == "0" ]
  then
    echo ${title}似乎已经运行，请检查pid为${pid}的进程。
    continue
  fi
  
  /usr/bin/ss-server -f ${title}.pid -p $port -k $passwd -m aes-256-cfb --fast-open $cmd
  
  done 


}


stop () {

  ls *.pid | while read line
  do
    kill $(cat $line)
    rm $line
  done

}

if [ $cmd == "start" ]
then
  start
elif [ $cmd == "stop" ]
then
  stop
elif [ $cmd == "restart" ]
then
  stop
  start
else
  echo 错误参数“$cmd”。参数应该是start或stop。
fi
