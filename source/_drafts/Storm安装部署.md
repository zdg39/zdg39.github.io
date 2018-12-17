---
title: Storm安装部署
tags: Storm
---
storm启动出现找不到或无法加载主类 Files\Java\jdk1.8.0_171\bin;C:\Program
修改storm-config命令
将-Djava.library.path=%JAVA_LIBRARY_PATH%;%JAVA_HOME%\bin;%JAVA_HOME%\lib;%JAVA_HOME%\jre\bin;%JAVA_HOME%\jre\lib 改为
-Djava.library.path="%JAVA_LIBRARY_PATH%;%JAVA_HOME%\bin;%JAVA_HOME%\lib;%JAVA_HOME%\jre\bin;%JAVA_HOME%\jre\lib"
添加双引号去除空格
