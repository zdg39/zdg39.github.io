# zdg39.github.io
Z-Blog
Hexo(next主题)

# 分支Hexo和Master
Hexo分支作为整个博客站点仓库
主目录下public目录为Master分支存储博客文章

# next主题不能上传至git仓库中是因为在git中引用了子git仓库，可以使用以下命令。
git ls-files --stage | grep 160000

git rm --cached themes/next
