#!/usr/bin/env bash
git config user.name "StayZeal"
git config user.email "546294760@qq.com"
git add .
commit(){
  str="$1"
  #echo "$1"
  echo "开始提交：$str"
  if [ -z "$str" ]; then
     str="default commit msg"
  #else
  #  str="$1"
  fi
  git commit -m"$str"
  echo "提交信息：$str"
}
commit "$1"
git push
#打开网页
x-www-browser 'https://github.com/StayZeal/AndroidLearn'