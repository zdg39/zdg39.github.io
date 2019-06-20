<h1 align="center">Welcome to Z-Blog 👋</h1>
<p>
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="https://zdg39.github.io/">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" target="_blank" />
  </a>
  <a href="https://github.com/zdg39/zdg39.github.io/blob/hexo/LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" target="_blank" />
  </a>
</p>

> 个人博客:https://zdg39.github.io

### 🏠 [Homepage](https://github.com/zdg39/zdg39.github.io)

## 分支Hexo和Master

Hexo分支作为整个博客站点仓库 主目录下public目录为Master分支存储博客文章

## 分布式存储

首先克隆仓库hexo分支，安装nodejs和hexo，在仓库主目录下运行npm install命令，然后就可以使用hexo命令生成博客文章。
切换到public目录下，和master分支建立连接，使用public目录作为仓库master分支

## 问题总结

### 1,next主题不能上传至git仓库中是因为在git中引用了子git仓库，可以使用以下命令。

```sh
git ls-files --stage | grep 160000
git rm --cached themes/next
```

### 2,博文名称不能使用中文命名

集成gittalk评论博文名称不能太长最好使用英文,中文转码后会变长很多则会出现Error: Validation Failed

## Author

👤 **zdg &lt;zhudg39@gmail.com&gt;**

* Github: [@zdg39](https://github.com/zdg39)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/zdg39/zdg39.github.io/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2019 [zhudg39@gmail.com](https://github.com/zdg39).<br />
This project is [MIT](https://github.com/zdg39/zdg39.github.io/blob/hexo/LICENSE) licensed.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
