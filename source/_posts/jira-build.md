---
title: jira服务搭建
tags:
date: 2020-04-05 20:07:19
---

## 前言
本文为搭建jira服务的教程,jira版本为jira8.3.0,如果需要搭建的jira服务版本与该文不符可能部分步骤需要调整。本文为原创分享,可能有误望谅解。

## 依赖环境
- CentOS 64 Bit
- JDK1.8
- MySQL5.7
<!-- more -->

## 安装部署

安装jira之前需要提供java环境和MySQL,为jira服务创建数据库

```shell
mysqld [(none)]> create database jira default character set utf8 collate utf8_bin;
Query OK, 1 row affected (0.00 sec)

mysqld [(none)]> grant all on jira.* to 'jira'@'%' identified by 'jirapasswd';
Query OK, 0 rows affected (0.00 sec)

mysqld [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

直接在服务器上下载jira服务,测试环境部署的是8.3.0版本,如果需要安装其他版本修改8.3.0即可

```shell
#下载jira8.3.0的安装包
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-8.3.0-x64.bin
```

下载完成后为安装包增加运行权限,进行安装,安装配置步骤如下

```shell
#添加运行权限
chmod +x atlassian-jira-8.3.0-x64.bin

# 执行安装程序，进行安装：
[root@SzfyTestServer ~] ./atlassian-jira-software-8.3.0-x64.bin
Unpacking JRE ...
Starting Installer ...
Sep 29, 2018 8:23:26 PM java.util.prefs.FileSystemPreferences$2 run
INFO: Created system preferences directory in java.home.

# o确定安装，c取消
This will install JIRA Software 8.3.0 on your computer.
OK [o, Enter], Cancel [c]
o

# 选择1是使用默认安装路径，2为自定义安装,3为升级。
Choose the appropriate installation or upgrade option.
Please choose one of the following:
Express Install (use default settings) [1], Custom Install (recommended for advanced users) [2, Enter], Upgrade an existing JIRA installation [3]
1       

# 安装配置说明,http默认端口是8080,RMI端口是8085,在测试环境使用8082和8083代替
有关JIRA软件安装位置和将使用的设置的详细信息。
默认程序：/opt/atlassian/jira
默认数据：/var/atlassian/application-data/jira
HTTP端口：8080
RMI端口：8005
Details on where JIRA Software will be installed and the settings that will be used.
Installation Directory: /opt/atlassian/jira
Home Directory: /var/atlassian/application-data/jira
HTTP Port: 8082
RMI Port: 8003
Install as service: Yes
Install [i, Enter], Exit [e]
i

Extracting files ...

# 是否启动jira，不推荐直接启动，因为后面要添加jdbc的jar和破解的Jar包，不然中途还需重启，
Please wait a few moments while JIRA Software is configured.
Installation of JIRA Software 8.3.0 is complete
Start JIRA Software 8.3.0 now?
Yes [y, Enter], No [n]
n
Installation of JIRA Software 8.3.0 is complete
Your installation of JIRA Software 8.3.0 is now ready.
Finishing installation ...
```

由于jira没有mysql驱动程序,所以安装后需要上传mysql驱动程序
- mysql驱动下载:<a href="/files/jira/mysql-connector-java-5.1.48-bin.jar" target="_blank">mysql-connector-java-5.1.48-bin.jar</a>

```shell
cp -a  mysql-connector-java-5.1.48-bin.jar /opt/atlassian/jira/atlassian-jira/WEB-INF/lib/
```

安装成功后需要对jira进行破解,破解jira需要替换一个破解jar包atlassian-extras-3.2.jar。jira8.3.0对应的破解jar是atlassian-extras-3.2.jar,其他版本的jira查找对应的破解。此破解工具有效期到2033年2月8日，把atlassian-extras-3.2.jar复制到/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/目录下。覆盖其默认文件。
- 破解包下载:<a href="/files/jira/atlassian-extras-3.2.jar" target="_blank">atlassian-extras-3.2.jar</a>

```shell
cp -a atlassian-extras-3.2.jar /opt/atlassian/jira/atlassian-jira/WEB-INF/lib/
```

替换atlassian-extras-3.2.jar后就可以启动jira,启动成功后就可以在浏览器输入http://ip:8082访问,web界面的配置可以参考https://blog.51cto.com/moerjinrong/2287899

```shell
# 启动jira
service jira start
# 查看jira服务是否启动成功
ss -tnl | grep 8082
# jira日志
/opt/atlassian/jira/logs/catalina.out
# 关闭jira
service jira stop
```

## 问题解决(Q&A)

#### Q1:使用service jira start命令无法找到jira服务
 A1:一般情况下不是ROOT用户安装的jira无法注册到service服务,使用/opt/atlassian/jira/bin/start-jira.sh启动

#### Q2:jira未破解成功
A2:jira未破解成功可能是atlassian-extras-3.2.jar未替换成功.检查/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/目录下的atlassian-extras-3.2.jar是否是替换的破解包

#### Q3:无法连接到MySQL数据库
A3:检查数据库连接信息是否正确,账号配置等是否有权限,阿里云RDS是否配置白名单等

#### Q4:浏览器使用http://ip:8082无法访问
A4:检查阿里云ECS安全组是否开放8082端口
