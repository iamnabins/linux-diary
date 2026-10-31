# linux 基础操作
## （1）查看当前目录下的文件及文件夹：
1. `ll -h`: 即 `ls` + `-alFh` ，其中 `a` 表示查看隐藏文件， `l` 表示查看详细信息， `F` 表示查看文件的类型，`h` 表示将文件的大小用更为直观的方式显示
2. `pwd`: 即 **print working directory**，用于打印当前工作目录
3. 查看文本文件内容，使用 `cat 文件地址 `

## （2）新建目录和文件
使用 `mkdir` 和 `touch` 来分别新建空目录和空文件

### `mkdir` 命令
- 用途：创建空的目录，可以传多个目录来批量创建，默认若路径的父目录不存在则无法创建
- `-p`：该参数可以使当父目录不存在时一并创建
```bash
# 若当前工作目录为 /home/chriskim
mkdir test          # 新建 /home/chriskim/test/
mkdir /data/docs    # 新建 /data/docs/
mkdir a b c         # 新建 /home/chriskim/a/，/home/chriskim/b/，/home/chriskim/c/
mkdir x/y/z         # 报错 No such file or directory
mkdir -p x/y/z      # 新建 /home/chriskim/x/，/home/chriskim/x/y/，/home/chriskim/x/y/z/
mkdir -p proj/{x/y/z} # 新建 proj/x, proj/y, proj/z
```
### `touch`命令
- 用途：创建空文件，支持批量创建

 > `touch`命令本身没有 `-p` 参数，一般需要 `mkdir -p 目录 `来提前创建

## （3）查找文件和目录
当我们知道文件的一些大致信息时，我们会使用 `find` 命令来查找，find默认会从指定的目录开始，递归的依次向下查找文件和目录

同时介绍一下 `which`，`where is`, `locate`

 `find` 的一般结构如下：
 ```bash
 find [起始目录] [查询条件] [动作]
 ```
 常用的查找条件有：
 - `-name 名称` ：按照名称来查找，区分大小写
 - `-inname 名称` ：按照名称来查找，不区分大小写
 - `-type f` ：只找普通文件
 - `-type d` ：只找目录
 - `-maxdepth n`：最多向下查找几层目录
 - `-empty`：只找空文件
 - `-user tom`: 属主
 - `-prem  644`: 权限644
 - `-o` / `!`: 或者，取反
 
 动作需要加上`-exec`，后面接要做的操作

 ```bash
 find logs -name "*.log" -mtime +30 -size +1m -exec rm {} \; # 表示将每一个文件都执行一次清楚操作, {} 是一个前面传下来的变量的占位符，也就是每一个 *.log 文件，\ 是结束符
 ```
 ```bash
 iamnabins@LAPTOP-JIRKG8RP:~/code$ which ls
 /usr/bin/ls
 iamnabins@LAPTOP-JIRKG8RP:~/code$ whereis ls
 ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz # 程序，源码，手册页
 ```

> locate 文件名 , 用于查预先建好的数据库，数据库通常每天更新一次，所以新文件先upodatedb



 ## （4）复制对象
 使用 `cp` 命令来复制文件和目录：
 ```bash
 cp [要复制的对象路径] [复制的目标路径]
 ```
 - 复制目录时，需要加`-r`参数，否则cp命令会跳过其执行
 - `-a`参数可以归档，可以保留文件权限，修改时间等信息
 - 目标路径若父目录不存在，则会报错

 > `cp` 命令在本体和目标文件/目录一样时，会覆盖目标

 ## （5）移动对象
 使用 `mv` 命令来移动对象
 
 `mv` 的使用基本与 `cp` 类似，通常还会使用 `mv` 来对文件进行重命名

 ## （6）删除对象
 使用 `rm` 和 `rmdir` 来实现删除，可以批量传入路径
 主要有以下参数：
- `i` : 每次删除都询问
- `I` : 在危险情况询问，比如递归删目录，删除对象超过3个等
- `f` : 强制删除不询问
- `d` : 删空目录
- `r` : 递归删目录

至于 `rmdir` ，一般用 `rm -d` 实现。

> 在进行对象删除工作时，务必关注以下几点：
>
> 1. 文件路径检查有没有空格，这会被视为两个路径
> 2. 务必检查路径开头是否有 "/" 符号，这会被视为决定路径

## （7）分页查看文件
使用 `more` 和 `less` 命令来分页查看文件，通常使用 `less` 即可

- **核心参数**
    - 位置参数：查看的文件路径
    - +行号：从指定行开始显示
    - +/字符串：第一次匹配的敌方开始显示
    - -N：显示行号
    - -S：长行不换行

- **快捷键**
    - `space`：下一页
    - `enter` 或 `↓`：下一行
    - `↑`：上一行
    - `q` ：退出

## （8）查看文件头尾
使用 `head` 命令和 `tail` 命令来查看问价头尾

### `head` 命令
- 位置参数：查看的文件路径
- -n [行数]：要查看的行数，默认10行

### `tail` 命令
- 位置参数：查看的问价路径
- -n [行数]：要查看的行数，默认10行
- `-f`：持续追踪文件尾部，若增多则打印，适用于日志

## （9）统计文本信息

### `wc` 命令
```bash
wc notes.txt
3 9 48 notes.txt     # 3行，9个词，48个字节

wc -l notes.txt
3                    # 只显示行号

file notes.txt dir   # 根据文件内容来判断文件类型
notes.txt: ASCII text
dir:       directory 

stat a.txt           #stat 命令可以列出文件的详细信息
  File: a.txt
  size: 19              Blocks: 8          IO Block: 4096   regular file
Device: 8,48    Inode: 67661       Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/iamnabins)   Gid: ( 1000/iamnabins)
Access: 2026-10-31 19:25:35.865159089 +0800 # atime 最后读取时间
Modify: 2026-10-31 19:25:31.405159087 +0800 # mtime 最后修改时间，ls -l 显示的就是这个
Change: 2026-10-31 19:25:31.405159087 +0800 # ctime 属性最后修改时间（权限，属主）
 Birth: 2026-10-31 19:25:16.993159090 +0800 # 创建时间
```

## （8）vim 和 nano
### 1. `vim` 
`vim` 有三种模式
- 普通模式
- 命令模式：使用 `:` 来进入
- 插入模式：普通模式下按 `insert` 进入
> 可通过 `Esc` 来退回到普通模式

常用的方法
- `:set number`：显示行号
- `:行号`：跳转到对应行
- `/字符串`：查找对用字符串

### 2. `nano`
- `nano`可以传入 `-l` 参数来显示行，如 `nano -l a.txt` 
- 使用 `ctrl`+`s` 来保存文件，使用 `ctrl` + `x` 来退出编辑器
- 其他的快捷键会显示在编辑器的下方

## （9）重定向

**重定向分为以下几种：**
- `<`: 重定向输入
- `>`: 重定向输出，会覆盖文件
- `>>` :重定向追加
- `2>` :错误信息输出，会覆盖
- `2>>` :错误信息追加
- `&>`：标准输出 + 标准错误一起重定向
- `2>&1`：把标准错误重定向到标准输出

```bash
ls /etc/hostname /nope > /dev/null 2>&1   # 将标准输出放到 "黑洞" 中，并且错误输出也输出到里面去

iamnabins@LAPTOP-JIRKG8RP:~/code$ wc -l a.txt
1 a.txt
iamnabins@LAPTOP-JIRKG8RP:~/code$ wc -l < a.txt
1

iamnabins@LAPTOP-JIRKG8RP:~/code$ cat > a.txt << EOF  # 使用 << 会进入交互模式，将交互输入的东西存起来，在检测到结束符之后，将其提交给前面的命令
> 你好，我是linux小猫
> 我喜欢一切美好
> NEVER
> GIVE 
> EOF
iamnabins@LAPTOP-JIRKG8RP:~/code$ cat a.txt
你好，我是linux小猫
我喜欢一切美好
NEVER
GIVE
```

## （10）命令连接
用于将多个命令组合在一起运行，常用的连接符号有：
- `;`；依次运行
- `&&`：前一个成功才运行下一个
- `||`：前一个失败才运行下一个
- `|` ：管道符号，用于将前一个命令的输出连接到下一个命令的输入

这里我们演示一下管道符号：
```bash
ll | head -n 50
cat console.log | head -n 50 | tail -n 25    # 查看 26-50 行的内容
```

## （11）变量

**使用变量的方法:**

1. 使用 `=` 来给变量赋值
2. 使用 `$变量名` 或 `${变量名}` 来获取变量值
3. 通过 `${变量}abc` 来拼接
4. 使用 `unset` 命令来删除变量

## （12）引号问题
> 引号分为单引号和双引号，其中单引号中的所有字符都会被当作纯文本处理，而双引号中的变量会做解释处理

```bash
>>> find . -name "*.txt"  # 查找 txt 文件

>>> os=alice
>>> find . -name "${os}.txt" # 查找名为 alice.txt 的文件
```

## （13）用户和用户组

**查看当前用户**
- `whoami`: 查看当前用户的用户名
- `id`: 查看当前用户的详细信息
- `groups`: 查看当前用户所属的组

**常用命令**
- `passwd` + `用户名`: 修改用户密码，不填用户则默认修改自己的密码
- `su` + `用户名`: 切换用户，可以添加 `-` 或 `-l` 参数来以 shell 的方式切换

## （14）root 和 sudo
> 使用 `sudo` 提权到 root 权限，需要输入当前用户密码；使用 `-i` 参数可以进入root的shell

## （15）修改对象的所有者和用户组
- 命令：`chown`
- 核心参数：
    - 位置参数1：目标值，格式为 `[用户名]:[用户组]`，如果只修改用户组要保留 `:` 
    - 位置参数2：目标对象路径，如果要递归地修改一个目录及它内部的对象，要使用 `-R` 参数

比如：
```bash
chown -R iamnabins:iam dirs/
```

## （16）修改对象的权限
- 方法一：`chmod`
    - 实例：`chmod 777 -R dirs/`

- 方法二：字母实现
    - `u`: 所属用户
    - `g`: 组内用户
    - `o`: 其他用户
    - `a`: 所有用户
    - > 实例：chmod u=rwx g=rw o=rw main

## （17）软件包管理

软件包管理需要root权限，使用 `sudo -i` 临时提权
- 刷新软件包：
    - `sudo apt update`
- 下载包：
    - `sudo apt install [软件包名] `，可以加入 `-y` 参数来跳过确认，可以批量下载
- 搜索包：
    - `apt search [软件包名]`，无需sudo权限
- 列出安装的软件包：
    - `apt list --installed`
- 卸载软件包:
    - `sudo apt remove [软件包名]` ，不删除依赖
- 彻底卸载软件包: 
    - `sudo apt purge [软件包名]`，删除依赖
- 自动删除无用依赖: 
    - `sudo apt autoremove` 

## （18）远程操作
- 使用 `ssh` 来远程连接
    - 格式：`ssh 用户名@主机地址`，可以使用 `p` 参数来指定端口，默认为 22
    - 第一次连接需要输入远程用户的密码，（类似 cookie ？？？）
    - 使用 `exit` 来退出
---
- 使用 `scp` 来传文件
- 核心参数
    - 原始对象路径
    - 目标对象路径
    - `r`：递归传目录
    - `-P`：指定端口，默认 22

其中，远端的路径可以用 `ssh 用户名@主机地址:路径`，例如 `iamnabins@1.2.3.4:~/data`

## （19）变量和环境变量
变量可以存储值，在前面，我们使用 `$var` 来获取变量值，但这个变量只适用于当前启动的 shell，无论是下一次启动还是当前shell开启的子进程程序，都不会获得这类普通变量
1. 使用 `export` 字段来使得这个变量能响应整个shell和他的子程序
2. 特殊环境变量也可以暂时的用于当前shell，使用 `export ``$PATH="opt/myapp/bin:$PATH"`
3. 如果要添加始终生效的环境变量：
```bash
echo 'export PATH="/opt/myapp/bin:$PATH"' >> ~/.bashrc # 这里的 export 同样不能省，不然不会传递给子进程
source ~/.bashrc # 立即刷新
```
## 补充操作
- `watch`: 用于重复执行操作，最简单的用法：`watch -n 3 -d date`（每 3 秒刷新一次当前时间，并高亮变化的部分）
- `tee` : 同时输出到终端和文件
    - `ls | tee a.txt`
- `diff -u [文件1] [文件2]`：`-u` 用于统一格式
- `uname -a`：查看系统和内核信息


# linux 进阶/专项操作
## 后台任务处理，此处使用 `tmux`
- 核心参数：
    - `tmux new -s [会话名]`，输入后会直接进入，使用 `ctrl` + `b`,松开再 `d` 来使会话在后台工作
    - `tmux attach -t [会话名]`，进入会话
    - `tmux ls`，列出已存在会话







