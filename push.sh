#!/usr/bin/env bash
git add .
commit(){
  str="$1"
  echo "开始提交：$str"
  if [ -z "$1" ]; then
     str="default commit msg"
  else
     str="$1"
  fi
  git commit -m"$str"
  echo "提交信息：$str"
}
commit
git push