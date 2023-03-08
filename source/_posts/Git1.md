---
title: Git系列之解决合并分支冲突
date: 2018-06-08 21:05:24
tags: Git
---

  在使用git时，通常会建立几个分支来管理不同环境的代码，通常会建立develop，test，master等几个分支来管理开发，测试，生产环境的代码。通常master分支固定一个版本，develop分支迭代开发新的功能，当开发完新的功能时将develop分支合并到test分支，将test分支的代码打包发布到测试服务器测试通过后再将test分支合并到master分支以更新正式生产环境新的版本。当然也可以建立管理其他分支，例如在测试服务器和正式服务器之间还需要灰度服务器来过渡，这时可以建立一个gray分支来管理灰度服务器的代码；也可以建立一个专门用来修复bug的分支，当生产环境出现bug时，开发人员从master分支新建一个temp分支，在temp分支上修复bug，当修复完成后再将temp分支合并回master分支。
  <!-- more -->
  git鼓励大家多使用分支，在开发新的模块时每一个开发人员可以根据不同的模块以develop分支为基础来建立不同的分支，当开发完成时，再合并回develop分支。git的分支功能的确使得开发变得简单高效，但是分支之间的合并却并不简单，接下来所要介绍的便是一些合并分支出现冲突的解决办法。
# 一:版本回退解决冲突
  在合并分支时，如果只是单纯地进行两个分支之间的合并，假如这时存在冲突只需要接受其中我们所需要的一个版本即可，这种冲突情况解决无疑很简单。但仍然有一些比较复杂的情况，如果单纯地接受其中一个版本无疑会越加混乱。最近在公司使用git进行多人开发时遇见了一种合并冲突情况，于是将解决办法记录下来，大致情况是：远程有test和develop分支，本地有test和develop分支，因为开发时所用分支为test分支所以想要将test分支合并到develop分支以后便切换到develop分支开发。所做操作如下：

- 1 拉取分支test:
  - git pull origin test
- 2 切换到develop分支:
  - git checkout develop
- 3 合并分支test，有冲突接受test分支的版本:
  - git merge test
- 4 pull分支develop，有冲突并未检查直接add->commit->push:
  - git pull origin develop
  - git add .
  - git commit -m "some message"
  - git push origin develop

> 当合并两个分支时有冲突可以借助idea查看两个分支的区别。


进过上诉操作，这时远程分支develop已经被污染，解决办法如果是选用修改有冲突的文件无疑浪费很多时间，这时可以使用git的回退功能，具体操作如下：
- 1 在本地develop回退到合并test分支前一个版本:
  - git reset HEAD~1
- 2 使用-f选项将develop分支强制覆盖远程develop分支代码:
  - git push origin develop -f
- 3 重新拉取分支develop:
  - git pull origin develop
- 4 合并分支test,有冲突接受test分支的版本:
  - git merge test
- 5 push分支develop:
  - git push origin develop



# 二:使用git的储藏功能解决冲突
git还有一个功能十分强大，就是储藏(stash)功能，储藏会将你所做的修改保存在栈中，这时你就可以切换到其他分支进行工作。在团队合作开发中当你在本地更改一些文件后想要将将他们推送到远程仓库时这时发现有冲突，因为可能有其他团队成员更改了相同的文件并且将其推送到了远程仓库，这时你再往远程分支必定会有冲突。这时就可以使用到git的储藏功能，具体操作如下:
- 1 先将本地代码储藏下来:
  - git stash
- 2 将远程代码拉取下来:
  - git pull origin develop
- 3 恢复储藏的代码:
  - git stash pop
- 4 借助idea工具查看两个版本的区别，并决定接受哪个版本。

因为储藏的版本和远程仓库版本会存在冲突，这时恢复储藏时就相当于合并两个分支会存在冲突。
git的储藏功能也十分好用，以下介绍一些相关命令:
> git stash:储藏 </br>
  git stash pop:恢复最新的储藏</br>
  git stash list:显示有哪些储藏</br>
  git stash apply stashName:应用储藏stashName

  <center>持续更新中...
