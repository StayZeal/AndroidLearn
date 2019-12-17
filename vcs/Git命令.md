git checkout -b 本地分支名x origin/远程分支名x //拉取远程分支

git fetch origin 远程分支名x:本地分支名x

git log --author="wo"

git rebase -i

git commit --amend --author="StayZeal <test@test.com>"//修改用户名

===================git 忽略已被track的文件的修改======

git update-index --assume-unchanged multi/local.properties

//忽略根目录下的.htaccess文件

git update-index --assume-unchanged /.htaccess
 
//不再忽略

git update-index --no-assume-unchanged /.htaccess



git还有设置子仓库的功能：git sub...

git filter-branch -f --env-filter "GIT_AUTHOR_NAME='StayZeal'; GIT_AUTHOR_EMAIL='543294760@qq.com'; GIT_COMMITTER_NAME='StayZeal'; GIT_COMMITTER_EMAIL='543294760@qq.com';" HEAD

修改提交历史中的user name
```
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_NAME" = "unknown" ]
then
export GIT_AUTHOR_NAME="543294760@qq.com"
export GIT_AUTHOR_EMAIL="543294760@qq.com"
fi

if [ "$GIT_COMMITTER_NAME" = "unknown" ]
then
export GIT_COMMITTER_NAME="543294760@qq.com"
export GIT_COMMITTER_EMAIL="543294760@qq.com"
fi
'
```