---
title: Hexo
date: 2018-04-14 16:11:13
tags: 博客
---
# Hexo
## 一 :Linux环境(Ubuntu)
安装hexo博客框架之前首先在机器中安装好nodejs，使用node -v命令可以查看nodejs版本,npm -v命令可以查看npm版本。


### 1:安装Hexo
<!-- more -->    
#### 下载hexo
> npm install hexo-cli -g
输入hexo命令检查是否安装成功,出现hexo comand not found 检查环境变量是否配置


#### 初始化文件
> hexo init folderName

#### 切换至folderName
> cd folderName
在folderName下输入hexo命令出现：ERROR local hexo not found in folderName尝试升级nodejs版本，可以解决该问题

#### 下载hexo所需的一些依赖
> npm install

#### 生成静态文件
> hexo generate/hexo g

#### 启动hexo服务
> hexo server/hexo s

打开浏览器输入localhost:4000出现Hexo默认界面安装成功
### 2:自定义主题(next主题)
在 Hexo 中有两份主要的配置文件，其名称都是 _config.yml。 其中，一份位于站点根目录下，主要包含 Hexo 本身的配置；另一份位于主题目录下，这份配置由主题作者提供，主要用于配置主题相关的选项。
站点根目录下称为**站点配置文件**,主题目录下称为**主题配置文件**
#### 下载主题
> cd your-hexo-side
> git clone https://github.com/iissnan/hexo-theme-next themes/next 最新版本
#### 启用主题
克隆完成后,打开**站点配置文件**
> vim _config.yml 没有权限读写文件可以使用su root变为管理员
找到theme,将值改为next theme： next
#### 验证主题
在验证前可以使用hexo clean清理缓存
>hexo generate/hexo g 生成静态文件
hexo s --debug/hexo server --debug 启动hexo服务并开启debug
npm install 下载所需依赖，因为next目录下的.gitignore忽略node-modules所以需要重新下载

出现下列信息时
> INFO Hexo is running at http://0.0.0.0:4000/. Press Ctrl+C to stop.

可以打开浏览器输入:localhost:4000访问

#### 更多next主题个性化设置:http://theme-next.iissnan.com/getting-started.html
