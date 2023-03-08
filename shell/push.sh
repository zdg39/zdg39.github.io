#!/bin/bash
#Program：
#该脚本用来推送博客文件
#History：
#2018/5/26 朱德港 first release
echo "start generate blog's fiels"
hexo g
echo "success"

echo "start stage files"
git add .
echo "success"

echo "start commit fiels to local repository"
read -p "please input message:" message
git commit -m ${message}
echo "success"

echo "start push origin hexo"
git push origin hexo
echo "success"

echo "start checkout master"
cd public
echo "success"

echo "start stage files"
git add .
echo "success"

echo "start commit fiels to local repository"
read -p "please input message:" message
git commit -m ${message}
echo "success"

echo "start push origin master"
git push origin master
echo "success"
