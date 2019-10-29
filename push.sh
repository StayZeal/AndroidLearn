#!/usr/bin/env bash
git add .
commit(){
  str = $1
  if [ -z "$str" ]; then
    str = "default commit msg"
   fi
   git commit -m str
echo str
}
commit
git push