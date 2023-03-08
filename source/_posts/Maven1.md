---
title: Maven系列之管理不同环境的配置文件
date: 2018-06-02 22:15:43
tags: Maven
---
 # <center>Maven系列之管理不同环境的配置文件

> 在一个项目的开发-测试-生产过程中，需要配置不同的环境配置文件，例如db属性配置，redis连接属性等的配置。如果每次从开发环境发布到测试服务器或者发布到生产服务器上都要去修改配置文件无疑会十分混乱，所以可以使用maven来管理不同环境的配置文件提高效率。

## 一，环境

<!-- more -->
项目上线大概会经过开发，测试，生产等3种环境(还有可能会经过灰度环境)，这时应对不同的环境我们便需要配置对应数量的配置文件。

## 二，使用Maven

首先使用idea建立一个maven项目Demo1,在resource下建立dev,pro,test三个目录分别代表开发，生产，测试三种环境，在目录中新建db.properties文件，db.properties文件中填写数据库的连接信息，不同的环境填写在不同的目录下。大致结构目录如下：
<center> ![](/images/maven/环境配置/目录结构.png)
<center> 图一

添加完成后再pom.xml文件中填写以下配置:

```
<profiles>
       <!-- 本地开发环境 -->
       <profile>
           <id>dev</id>
           <properties>
               <profiles.active>dev</profiles.active>
           </properties>
           <activation>
               <activeByDefault>true</activeByDefault>
           </activation>
       </profile>
       <!-- 测试环境 -->
       <profile>
           <id>test</id>
           <properties>
               <profiles.active>test</profiles.active>
           </properties>
       </profile>
       <!-- 生产环境 -->
       <profile>
           <id>pro</id>
           <properties>
               <profiles.active>pro</profiles.active>
           </properties>
       </profile>
   </profiles>

   <!-- 打包配置-->
   <build>
      <resources>
          <resource>
              <directory>src/main/resources</directory>
              <filtering>true</filtering> <!-- 是否使用过滤器 -->
              <includes>
                  <include>**/*</include>
              </includes>
              <!-- 资源根目录排除各环境的配置，防止再生成目录中多余其它目录 -->
              <excludes>
                  <exclude>test/</exclude>
                  <exclude>pro/</exclude>
                  <exclude>dev/</exclude>
              </excludes>
          </resource>
          <resource>
              <directory>src/main/resources/${profiles.active}</directory>
          </resource>
      </resources>

      <finalName>Demo1</finalName>
      <plugins>

          <plugin>
              <artifactId>maven-compiler-plugin</artifactId>
              <configuration>
                  <source>1.7</source>
                  <target>1.7</target>
              </configuration>
          </plugin>

          <!-- Web Server Tomcat -->
          <plugin>
              <groupId>org.apache.tomcat.maven</groupId>
              <artifactId>tomcat7-maven-plugin</artifactId>
              <version>2.2</version>
              <configuration>
                  <path>/</path>
                  <uriEncoding>UTF-8</uriEncoding> <!--处理 GET 的中文-->
              </configuration>
          </plugin>

      </plugins>

  </build>
```
在pom文件中添加完成后打开idea右侧的maven projects视图，大致展现结果：
<center> ![](/images/maven/环境配置/maven视图.png)
<center> 图二

pom文件的配置自动加载的是dev下的配置，如果想要加载其他环境的配置只需要在图二中勾选其他环境然后点击左上角刷新按钮即可加载其他环境配置。当发布项目时可以使用-Pxxx选项来选择加载哪个目录下配置文件，例如-Ptest即加载test目录下的配置文件。

#### <center>初稿，后续会继续修改。。。。
