#!/usr/bin/env bash
git add .
commit(){
  str = "$1"
  if [ -z "$str" ]; then
     str = "default commit msg"
  fi
  git commit -m str
  echo "提交信息：$str"
}
commit
git push