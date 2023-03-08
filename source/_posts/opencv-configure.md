---
title: opencv的环境配置
tags: opencv
date: 2019-05-14 16:49:43
---

# <center>opencv的环境配置
最近由于工作原因有机会学习一下opencv,在本地开发测试通过将要发布时,在linux环境opencv一直编译不成功,之后不断尝试编译安装不同版本,最后为了同时支持本地功能开发和linux编译成功,最后降级为2.4.11版本终于成功。

## 一,开发环境安装opencv环境
-  首先在opencv[官网](https://opencv.org/releases/)找到特定的版本下载到本地,例如windows环境下载选择windows版本,由于演示所用的版本是2.4.11,所以下文linux安装演示所使用版本也是2.4.11;linux直接下载source编译安装即可.

<!-- more -->
<center> ![](/images/opencv/opencv-version.png)
</center>

---

- 下载opencv完成后将会得到opencv-2.4.11.exe,双击解压缩获得一个文件opencv;新建一个maven项目,在项目根目录下新建一个opencv目录;找到opencv中build下的java目录,将里面的内容拷贝至你的项目新建目录下

<center>
![](/images/opencv/opencv-idea.png)
</center>

---

- 修改maven项目的pom文件,将opencv-2411.jar包导入你的项目中
```
        <!-- 引入opencv -->
        <dependency>
            <groupId>opencv</groupId>
            <artifactId>opencv</artifactId>
            <version>2.4.11</version>
            <scope>system</scope>
            <systemPath>${project.basedir}/opencv/opencv-2411.jar</systemPath>
        </dependency>

        <build>
          <plugins>
            <!-- 打war包时将opencv的jar打到指定目录下 -->
            <plugin>
              <groupId>org.apache.maven.plugins</groupId>
              <artifactId>maven-dependency-plugin</artifactId>
              <version>2.10</version>
              <executions>
                  <execution>
                      <id>copy-dependencies</id>
                      <phase>compile</phase>
                      <goals>
                          <goal>copy-dependencies</goal>
                      </goals>
                      <configuration>
                          <outputDirectory>${project.build.directory}/${project.build.finalName}/WEB-INF/lib</outputDirectory>
                          <includeScope>system</includeScope>
                      </configuration>
                  </execution>
              </executions>
            </plugin>
          </plugins>
        </build>
```

---

- 在启动参数内添加-Djava.library.path=$PROJECT_DIR$\opencv\x64,根据你的系统选择是x64还是x86
- 新建一个测试类Test,使用opencv对图片进行灰度化

```
  import org.opencv.core.Core;
  import org.opencv.core.Mat;
  import org.opencv.highgui.Highgui;
  import org.opencv.imgproc.Imgproc;

  public class Test {
    static {
        System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    }

    public static void main(String[] args) {
        Mat image = Highgui.imread("D://opencv.png");
        Mat imageGray = new Mat();
        Imgproc.cvtColor(image,imageGray,Imgproc.COLOR_RGB2GRAY);
        Highgui.imwrite("D://opencv-gray.png",imageGray);
    }
}
```

如果Test类可以正常运行可以得到一张灰度化后的图片

<center>![](/images/opencv/opencv.png)
原图
</center>

<center>![](/images/opencv/opencv-gray.png)
灰度化后的图
</center>

到这里已经可以在开发环境使用opencv了,更多教程可以参考官方文档.

## 二,linux安装opencv环境
上文展示了如何在开发环境搭建opencv,但是在实际应用中需要在linux服务器上搭建。在liunx上搭建只需要安装一些依赖编译源码即可,下列教程演示如何安装opencv并且在war包可以正常使用opencv,war包部署在tomcat服务器。

- 安装依赖
sudo yum groupinstall "Development Tools" -y

sudo yum install gcc cmake gtk2-devel numpy pkgconfig -y

- 安装ant
yum -y install ant

- 下载opencv压缩包(2.4.11版本安装成功)
wget https://github.com/opencv/opencv/archive/2.4.11.zip

- 在opencv目录下建立build目录并且切换到build目录

- cmake编译
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -DBUILD_TESTS=OFF ..

- make
  - make -j8  这一步比较慢,需要等待一段时间,安心等待完成后执行下一步即可
  - sudo make install
  成功后再build目录下的bin目录得到一个jar包

- 在/usr/local/share/OpenCV/java/ 下找到libopencv_java320.so和  opencv-320.jar两个文件,将他们复制到配置的java.library.path路径下

- 启动tomcat即可使用opencv
