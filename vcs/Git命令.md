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
