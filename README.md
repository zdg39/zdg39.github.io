# zdg39.github.io
Z-Blog
Hexo(next主题)

# next主题不能上传至git仓库中是因为在git中引用了子git仓库，可以使用以下命令。
git ls-files --stage | grep 160000
git rm --cached themes/next
