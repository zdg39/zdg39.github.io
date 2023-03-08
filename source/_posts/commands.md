---
title: 常用指令总结
date: 2018-12-17 19:38:15
tags: 工具
---
# 一:数据库

### MySql
- #### 连接数据库
mysql -h host -u username -p password
- #### 设置字符集
set names utf8
<!-- more -->

### show命令
- #### 显示系统变量的名称和值
show variables
- #### 显示一些系统特定资源的信息
show status
- #### 显示系统中正在运行的所有进程
show [full] processlist
- #### 显示当前会话语句(需要使用SET profiling = 1开启prifile)
show profiles
- #### 显示语句工作情况和消耗时间情况
show profile [cpu,block io,all,...] for query queryId

---

### Redis
- #### 连接数据库
redis-cli -h host -p port -a "password"
- #### 查询所有可用的key
key *
- #### 选择数据库
select db
- #### 内存分析(info命令)
info memory

---

- #### 向有序集合添加元素
zadd sorted_set_name score id
- #### 查看有序集合某个元素的分数
zscore sorted_set_name id
- #### 由高到低查看有序集合的id(0,-1代表元素下标)
zrevrange sorted_set_name 0 -1
- #### 由高到低查看有序集合的id并且带上分数(0,-1代表元素下标)
zrevrange sorted_set_name 0 -1 withscores
- #### 由低到高查看有序集合的id(0,-1代表元素下标)
zrange sorted_set_name 0 -1
- #### 由低到高查看有序集合的id并且带上分数(0,-1代表元素下标)
zrange sorted_set_name 0 -1 withscores
- #### 获取某个元素的排行
zrevrank sorted_set_name id
- #### 增加某个元素的分数,元素不存在默认初始值为0
zincrby sorted_set_name score id
- #### 删除某个元素
zrem sorted_set_name id
- #### 删除有序集合
del sorted_set_name

---

### MongoDB
- #### 使用默认端口连接MongoDB
mongo host
- #### 连接MongoDB并指定端口
mongo host port
- #### 连接到指定的MongoDB数据库
mongo host port/dbName
- #### 指定用户名和密码连接到指定的MongoDB数据库
mongo host port/dbName -u username -p password

---

- #### 导出数据(--type后接json或cvs文件，-f后接字段双引号内用逗号隔开)
mongoexport -h host -u username -p password -d dbname -c collectionname -o file --type json/csv -f field
- #### 导入数据(--headerline 如果导入的格式是csv，则可以使用第一行的标题作为导入的字段，其他同导出数据)
mongoimport -h host -u username -p password -d dbname -c collectionname --file filename --headerline --type json/csv -f field



# 二:Git
### stash功能
- #### 暂存(保存在git整个栈中)
git stash
- #### 设置保存名
git stash save "stashName"
- #### 查看暂存列表
git stash list
- #### 恢复最近一次暂存，从暂存列表中删除
git stash pop
- #### 应用某一次暂存，暂存列表中不删除
git stash aplly "stashName"

---

### 回退功能
- #### 回退到指定版本
git reset --hard "commit id"

---

### 分支对比
- #### 对比两个分支不同
git log dev...master
- #### 对比两个分支提交的不同
git log --left-right dev...master
- #### 一个分支比另一个分支多
git log dev..master
- #### 一个分支有另一个分支没有
git log dev ^master

---

### rebase功能(合并本地仓库的多个commit,不要修改已经提交到远程仓库的commit)
- #### 合并本地3个commit
git rebase -i HEAD~3 

# 三:NodeJs
### hexo
- #### 新建一个页面
hexo new "pageName"
- #### 新建一个草稿
hexo new draft "draftName"
- #### 生成静态文件
hexo generate/hexo g
- #### 启动hexo服务
hexo server/hexo s
- ##### 部署发布
hexo deploy/hexo d

---

# 四:Java
- #### 查看进程状态
jstack pid
- #### 查看当前堆中的各个对象的数量和大小(增加live只打印活跃的对象)
jmap -histo[:live] <pid>
- #### 查看java堆的配置情况和使用的GC算法
jmap -heap <pid>
- #### 查看等待执行finalize方法的对象
jmap -finalizerinfo <pid>
- #### dump当前堆的对象(增加live只打印活跃的对象)
jmap -dump:[live,]format=b,file=<filename> <pid>

---

### jar命令
- #### 更新jar包中的类
jar -uvf jarName dirName/className.class

---

# 五:Linux
### 文件安装
- #### 安装deb文件
dpkg -i <package.deb>
- #### 移除一个已安装的包裹
dpkg -r <package>
- #### 安装rz
yum install lrzsz  -y

---

### 性能分析
- #### 查看进程cpu，内存使用率
top
- #### 查看进程下各个线程的cpu使用情况
top -Hp pid
- #### 查看端口连接人数:
netstat -na | grep ESTAB | grep 8080 | wc -l
- #### 查看网络信息  每秒统计一次:
sar -n TCP,ETCP 1

---

### 远程登录
- #### 管理远程主机，可做mysql，redis服务器的连接测试
telent ip port
- #### 远程登录，免密码登录
ssh user@ip
- #### 向远程主机发布命令
ssh user@ip "command"
- #### 向远程服务器发布文件
scp localfile user@ip:folder
- #### 向远程服务器发布目录
scp -r localfolder user@ip:folder

---

### 定时任务
- #### 添加定时任务
crontab -e
- #### 展示所有定时任务
crontab -l
- #### 删除定时任务
crontab -r

---

# 六:Storm
- #### 启动ui界面,在nimbus节点上使用
storm ui
- #### 启动nimbus,在nimbus节点上使用
storm nimbus
- #### 启动supervisor,在supervisor节点使用
storm supervisor
- #### 向集群提交拓扑
storm jar [ topology_jar ]  [ topology_class ] [ topology_name]
- #### 关闭已经部署的 Topology
storm kill [ topology_name [- w wait_time]
- #### 停止特定的Topology的Spout发射Tuple
storm deactivate [topology_name]
- #### 重新恢复特定Topology的Spout发射Tuple
storm activate [topology_name]
- #### 指示Storm在集群的Worker之间重新平均分派任务不需要关闭或者重新提交现有的Topology,一个新的Supervisor节点添加到一个集群中,就需要执行这个命令
storm rebalance [topology_name] [-w wait_time] [-n worker_count] [-e component_name=executer_count]

---

# 七:adb命令(Android调试工具)
- #### 查看当前连接的设备
adb devices
- #### 连接设备
adb connect ip:port

---

# 八:Python
### 包管理工具(pip)
- #### 下载最新版本的包
pip install packageName
- #### 下载指定版本的包
pip install packageName=version
- #### 下载最小版本
pip install 'packageName>=version'
- #### 升级包
pip install --upgrade packageName
- #### 卸载包
pip uninstall packageName
- #### 搜索包
pip search packageName
- #### 列出已安装的包
pip list
- #### 查看可升级的包
pip list -o
- #### 显示安装包信息
pip show
- #### 查看指定包的详细信息
pip show -f packageName

### scrapy
- #### 查看命令的详细信息
scrapy command -h
- #### 创建一个scrapy项目
scrapy startproject project_name
- #### 创建一个spider
scrapy genspider spider_name mydomain.com
- #### 运行一个spider
scrapy crawl spider_name

---

# 九:Arthas
- #### 方法内部调用路径,并输出方法路径上的每个节点上耗时
trace com.xxx.ClassName methodName
