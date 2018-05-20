# zdg39.github.io
Z-Blog
Hexo(next主题)

# 分支Hexo和Master
Hexo分支作为整个博客站点仓库
主目录下public目录为Master分支存储博客文章

# 分布式存储
首先克隆仓库hexo分支，安装nodejs和hexo，在仓库主目录下运行npm install命令，然后就可以使用hexo命令生成博客文章。

切换到public目录下，和master分支建立连接，使用public目录作为仓库master分支

# 问题总结
## next主题不能上传至git仓库中是因为在git中引用了子git仓库，可以使用以下命令。
git ls-files --stage | grep 160000

git rm --cached themes/next
