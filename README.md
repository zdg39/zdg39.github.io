<h1 align="center">Welcome to Z-Blog 👋</h1>
<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="https://zdg39.github.io/">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" target="_blank" />
  </a>
  <a href="https://github.com/zdg39/zdg39.github.io/blob/hexo/LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" target="_blank" />
  </a>
  <!-- [![GitHub stars](https://img.shields.io/github/stars/zdg39/zdg39.github.io.svg?style=social&label=Stars)](https://github.com/zdg39/zdg39.github.io)
  [![GitHub forks](https://img.shields.io/github/forks/zdg39/zdg39.github.io.svg?style=social&label=Fork)](https://github.com/zdg39/zdg39.github.io) -->
</p>

> 个人博客:https://zdg39.github.io

### 🏠 [Homepage](https://github.com/zdg39/zdg39.github.io)

## 分支 Hexo 和 Master

Hexo 分支作为整个博客站点仓库 主目录下 public 目录为 Master 分支存储博客文章

## 分布式存储

首先克隆仓库 hexo 分支，安装 nodejs 和 hexo，在仓库主目录下运行 npm install 命令，然后就可以使用 hexo 命令生成博客文章。
切换到 public 目录下，和 master 分支建立连接，使用 public 目录作为仓库 master 分支

## 问题总结

### 1,next 主题不能上传至 git 仓库中是因为在 git 中引用了子 git 仓库，可以使用以下命令。

```sh
git ls-files --stage | grep 160000
git rm --cached themes/next
```

### 2,博文名称不能使用中文命名

集成 gittalk 评论博文名称不能太长最好使用英文,中文转码后会变长很多则会出现 Error: Validation Failed

### 3,关闭 jekyll 自动化发布

GitHub Actions 发布后，我们在启用了 pages 后可以在 actions 界面中看到一条默认的 pages-build-deployment workflow，里面默认会使用 jekyll 来 build 页面，上传制品，然后进行 deploy 发布页面。如果需要关闭可以在 pages 根目录下创建 .nojekyll 文件。

## Author

👤 **zdg &lt;zhudg39@gmail.com&gt;**

- Github: [@zdg39](https://github.com/zdg39)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/zdg39/zdg39.github.io/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2019 [zhudg39@gmail.com](https://github.com/zdg39).<br />
This project is [MIT](https://github.com/zdg39/zdg39.github.io/blob/hexo/LICENSE) licensed.

---

_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
