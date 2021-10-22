#!/bin/bash

## 变量
IP="192.168.1.1"
PROJECT="projectName"
ENTER_FILE="index.html"
SERVER_PATH="/usr/nginx"
OUTPUT_PATH="./dist"
OLD_FILES=""
NEW_FILES=""
SCP_FILES=""
REMOVE_FILES=""

## 存储旧打包文件
if [ -d $OUTPUT_PATH ]
then
  cp -r $OUTPUT_PATH "${OUTPUT_PATH}_old"
  for file in `ls ${OUTPUT_PATH}_old`
    do
      if [[ -f "${OUTPUT_PATH}_old/${file}" && ${file} != $ENTER_FILE ]]
      then
        OLD_FILES="${OLD_FILES} ${file}"
      fi
    done
fi

## 开始代码打包
#rm -rf node_modules
#rm -rf package-lock.json
pnpm i --no-frozen-lockfile
pnpm run build

## 在新打包文件中查找需要上传的文件
for file in `ls ${OUTPUT_PATH}`
  do
    if [[ ${OLD_FILES} != *${file}* ]]
    then
      SCP_FILES="${SCP_FILES} ${file}"
    fi
    if [[ -f "${OUTPUT_PATH}/${file}" && ${file} != $ENTER_FILE ]]
    then
      NEW_FILES="${NEW_FILES} ${file}"
    fi
  done

## 查找需要删除的旧文件
if [ -d "${OUTPUT_PATH}_old" ]
then
  for file in `ls ${OUTPUT_PATH}_old`
    do
      if [[ ${NEW_FILES} != *${file}* ]]
      then
        REMOVE_FILES="${REMOVE_FILES} ${file}"
      fi
    done
  rm -rf "${OUTPUT_PATH}_old"
fi

## 将打包后的文件发送给服务器
ssh -p2222 root@${IP} "cd ${SERVER_PATH} && if [ ! -d $PROJECT ]; then mkdir $PROJECT; fi && cd $PROJECT && if [ ! -d $OUTPUT_PATH ]; then mkdir $OUTPUT_PATH; fi && cd $OUTPUT_PATH && rm -rf $REMOVE_FILES"
cd $OUTPUT_PATH
scp -P2222 -rp $SCP_FILES root@${IP}:${SERVER_PATH}/${PROJECT}/${OUTPUT_PATH#./}
exit
