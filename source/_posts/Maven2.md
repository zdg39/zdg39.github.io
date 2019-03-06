---
title: Maven系列之替换jar包中的类
date: 2019-02-27 13:15:36
tags: Maven
---
 # <center>Maven系列之替换jar包中的类

> 在maven项目中引入第三方jar包时，某些特殊情况下第三方jar包无法满足我们的需求，这时可以对第三方jar包某些类进行修改，重新依赖新的jar包。

## 一，准备

<!-- more -->
本文替换的jar包是littleproxy,在替换前新建一个maven项目demo,引入依赖littleproxy,pom文件如下:
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.demo</groupId>
    <artifactId>demo</artifactId>
    <version>1.0-SNAPSHOT</version>

   <dependencies>
       <dependency>
           <groupId>org.littleshoot</groupId>
           <artifactId>littleproxy</artifactId>
           <version>1.1.2</version>
       </dependency>
   </dependencies>
</project>
```
引入依赖成功后下载littleproxy的source文件，可以在idea的maven视图中下载。
<center> ![](/images/maven/替换jar包的类/source.png)

## 二，替换
根据不同的情况替换你想要替换的类，例如将ProxyUtils类的stripHost方法输出一下uri,在替换前该方法是:
```
public static String stripHost(final String uri) {
        if (!HTTP_PREFIX.matcher(uri).matches()) {
            // It's likely a URI path, not the full URI (i.e. the host is
            // already stripped).
            return uri;
        }
        final String noHttpUri = StringUtils.substringAfter(uri, "://");
        final int slashIndex = noHttpUri.indexOf("/");
        if (slashIndex == -1) {
            return "/";
        }
        final String noHostUri = noHttpUri.substring(slashIndex);
        return noHostUri;
    }
```
首先找到ProxyUtils的完整包名,在idea中搜索到ProxyUtils的完整包名是org.littleshoot.proxy.impl,为了防止包名不一致,所以在demo项目中新建一个包名org.littleshoot.proxy.impl,将littleproxy的source中的ProxyUtils拷贝至demo项目中,最终效果如下:
<center> ![](/images/maven/替换jar包的类/ProxyUtils.png)

这时在stripHost方法中添加输出uri:
```
public static String stripHost(final String uri) {
       System.out.println(uri);
       if (!HTTP_PREFIX.matcher(uri).matches()) {
           // It's likely a URI path, not the full URI (i.e. the host is
           // already stripped).
           return uri;
       }
       final String noHttpUri = StringUtils.substringAfter(uri, "://");
       final int slashIndex = noHttpUri.indexOf("/");
       if (slashIndex == -1) {
           return "/";
       }
       final String noHostUri = noHttpUri.substring(slashIndex);
       return noHostUri;
   }
```

在demo项目下新建libs目录,找到littleshoot在本地maven仓库的jar包littleproxy-1.1.2.jar,复制后粘贴到libs,如下所示:
<center> ![](/images/maven/替换jar包的类/libs.png)

编译ProxyUtils,用winrar打开libs下的littleproxy-1.1.2.jar,删除ProxyUtils.class，将编译后的ProxyUtils.class文件复制粘贴进去替换。修改pom文件如下所示:
> 更新jar包可以使用jar -uvf littleproxy-1.1.2.jar ProxyUtils.class所在目录/ProxyUtils.class文件

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.demo</groupId>
    <artifactId>demo</artifactId>
    <version>1.0-SNAPSHOT</version>

   <dependencies>
       <dependency>
           <groupId>org.littleshoot</groupId>
           <artifactId>littleproxy</artifactId>
           <version>1.1.2</version>
           <scope>system</scope>
           <systemPath>${project.basedir}/libs/littleproxy-1.1.2.jar</systemPath>
       </dependency>
   </dependencies>
</project>
```

这时所引入的依赖就是修改后的littleshoot。
