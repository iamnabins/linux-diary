# linux 一些规定，基础知识的介绍

## （1）linux 的执行层级
层级由上至下，依次是：  
1.程序  
2.shell  
3.内核  
4.硬件设备    

> 在终端敲命令时，其实就是在使用shell向内核下命令，并让内核执行。

## （2）Linux 文件的管理
Linux 文件都放在一个根目录下，通常有以下目录：

1. `bin`：存放基本命令（`/usr/bin`）
2. `sbin`：存放管理命令（`/usr/sbin`）
3. `boot`：内核，引导程序
4. `dev`：设备文件
5. `etc`：配置文件
6. `home`：普通用户的家目录
7. `root`：root用户的家目录
8. `lib`：共享库（`/usr/lib`）
9. `media`：自动挂载，如U盘光盘
10. `mnt`：临时手动挂载
11. `opt`：第三方软件
12. `tmp`：临时文件
13. `proc`：虚拟，进程与内核信息（放在内存里，不占据硬盘空间）
14. `usr`：程序和库（Unix软件资源）
15. `var`：常变化的数据，例如日志（`/var/log`）

## （3）文件的类型
| 字段 | 值 | 说明 |
|:--|:--|:--|
| 类型+权限 | `-rw-r--r--` | 第 1 个字符表示文件类型：`-` 普通文件、`d` 目录、`l` 符号链接、`c` 字符设备、`b` 块设备、`s` 套接字、`p` 管道。后 9 位分三组（属主/属组/其他人）的 `rwx` 权限，`r` 读、`w` 写、`x` 执行、`-` 无权限。此处表示普通文件，属主可读写，属组和其他人只读 |
| 硬链接数 | 1 | 指向该文件 inode 的硬链接数量。普通文件通常为 1；目录的该值至少为 2（自身 `.` 加父目录中的条目）。删除文件只是减少链接数，减到 0 才真正释放数据块 |
| 属主 | stu | 文件所有者（owner）的用户名，决定属主权限位（前 3 位）对谁生效。可用 `chown` 修改 |
| 属组 | stus | 文件所属的用户组（group），决定属组权限位（中间 3 位）对哪些用户生效。可用 `chgrp` 或 `chown :组` 修改 |
| 大小(字节) | 48 | 文件内容占用的字节数。对普通文件是实际大小；对目录通常是目录项本身占用的块大小（非目录内文件总大小）；对符号链接是链接目标路径字符串的长度 |
| 修改日期 | Oct 25 09:30 | 文件**内容**最后被修改的时间（mtime）。`ls -l` 默认显示 mtime；还有 atime（访问时间，`ls -lu`）和 ctime（inode 状态变更时间，`ls -lc`）。超过约 6 个月会显示年份而非时分 |
| 文件名 | notes.txt | 文件或目录的名称。以 `.` 开头为隐藏文件（需 `ls -a` 才显示）；符号链接后用 `->` 显示指向目标 |


## （4）inode
| 概念 | 核心说明 |
|:--|:--|
| **inode（索引节点）** | Linux 文件系统中用于存储文件元数据的数据结构。每个文件都有唯一的 inode，里面包含了文件的类型、权限、属主、属组、大小、时间戳（atime/mtime/ctime）、链接数以及数据块指针，但**不包含文件名**。 |
| **数据块（Data Block）** | 磁盘上真正用于存储文件内容（数据）的物理单元。inode 中记录着指向这些数据块的指针，系统通过指针找到并读取文件的实际内容。 |
| **文件名（Filename）** | 本质上只是方便人类阅读和记忆的标签。文件名并不存储在 inode 中，而是作为目录内容的一部分存在。 |
| **目录（Directory）** | 目录本质上也是一个特殊的文件。它的“文件内容”是一张映射表，专门记录了该目录下的**文件名**与对应的 **inode 编号** 的对应关系。 |
| **inode 编号** | 操作系统用于唯一标识一个 inode 的整数编号。目录通过记录文件名和 inode 编号的映射，帮助系统定位到具体的文件节点。 |
| **文件访问寻址过程** | 当访问一个文件时，系统首先在所在目录的数据中查找该文件名，获取其对应的 inode 编号；然后根据编号找到对应的 inode；最后通过 inode 中的数据块指针，去读取实际的数据块内容。 |

$\text{文件名} \xrightarrow{\text{① 目录映射}} \text{inode 编号} \xrightarrow{\text{② inode 表}} \text{inode 节点} \xrightarrow{\text{③ 数据块指针}} \text{数据块}$

> 其中 `ls -i` 可以看到每个文件的 inode 号

## （5）链接
链接分为硬链接和软链接  
某个对象的链接数：本质上是其inode被多少个“文件名/目录”指向了

- 硬链接：`ln notes.txt hard.txt`，两者的链接数 1->2（原先的1链接就是文件名和inode的链接产生），本质是目录给出的文件名和inode的映射表里面，两个文件名 **同时映射到了同一个inode** （注意，这段命令的意思是创建一个指向 `notes.txt` 的文件 `hard.txt`  
只有当两者都删除时，链接数归零，数据才被释放，
    - 目录的硬链接数 = 2 + 该目录下直接包含的子目录数量

- 软链接：`ln -s notes.txt soft.txt`，类似 windows 的快捷方式,其 **inode 存储了 notes.txt 的路径** ，两者是独立的文件，其中 `soft.txt` (类型是"|"，也就是管道符)指向 `notes.txt` ， `softs.txt` 的内容就是`notes.txt`的地址。
    > 比如我现在把 `soft.txt` 指向的 `notes.txt` 给删掉了，那么：
    ```bash
    iamnabins@LAPTOP-JIRKG8RP:~/code$ head notes.txt
    i'am notes.txt
    iamnabins@LAPTOP-JIRKG8RP:~/code$ cat soft.txt
    i'am notes.txt
    iamnabins@LAPTOP-JIRKG8RP:~/code$ rm notes.txt;cat soft.txt
    cat: soft.txt: No such file or directory
    ```

## （6）文件默认权限
文件/目录新建后的默认权限由 `umask` 的值确认，`umask` 记录了要被剔除的权限。举个例子，假设 `umask` 的值是 `022(----w--w-)`，  
那么文件（最高权限是666，即rw-rw-rw-），就会变成 `rw-r--r--` ，目录（最高权限是777,即rwxrwxrwx），就会变成 `rwxr-xr-x`。

可以使用 `umask <umask值>` 来在当前shell临时修改，若要永久修改，需要写入 `.bashrc` 或 `/etc/profile`。

## （7）文件特殊权限
共有三种：
- SUID x
- SGID x
- STICKY t
---
用户的密码是存放在 `/etc/shadow` 里面的，只有root用户有权限去修改，而普通用户却可以使用 **passwd** 来修改自己的密码
```bash
$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 93640 Feb  3  2026 /usr/bin/passwd
```
可见，passwd 程序属主的执行权限是"s"，也就是**SUID**————任何人执行该程序时，该进程都会临时获取root权限，使得能够改写 `/etc/shadow`。  
`SUID` 只对二进制程序有效，对脚本无效。  可以使用以下命令来查找具有**SUID**权限的执行程序。
```bash
iamnabins@LAPTOP-JIRKG8RP:~/code/linux-diary$ find /usr/bin -perm -4000 -type f | sort | head -6   #-perm -4000，表示查找权限包含SUID.
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/fusermount3
/usr/bin/gpasswd
/usr/bin/mount
/usr/bin/passwd
```
---
`SGID`，即位于属组执行位的"s"，通常会将共同协作的目录设置**SGID**。这样，当某位成员在该目录里面新建文件时，
由于 "进入" 目录这个操作就已经把进入的成员的组权限变为了目录的对应的组（若没有这么做的话，新建的文件属组就会是该成员的主组，其他人就不一定能够访问了），
那么新建的文件也会是该权限，只要属组是该共享目录的属组，那么就可以进入访问内部每个人的文件。

---

`STICKY`(粘滞键)，显示在 "other" 的执行位的 "t"。  
该功能常用于tmp目录，这样，只有tmp的属主和属组才能删文件，其他人只能删除属于自己的文件。
```bash
$ ls -ld /tmp
drwxrwxrwt 6 root root 120 Nov  2 14:13 /tmp
```

以上三种特殊权限也有自己对应的数字：
1. SUID: 4
2. SGID: 2
3. STICKY: 1
以 `特殊权限数字` + `三位普通数字`
```bash
$ touch file1 file2; mkdir dir1 dir2
$ chmod 4755 file1
$ chmod 2770 dir1
$ chmod 1777 dir2
$ ls -ld file{1..2} dir{1..2}
drwxrws--- 2 iamnabins iamnabins 4096 Nov  2 14:25 dir1
drwxrwxrwt 2 iamnabins iamnabins 4096 Nov  2 14:25 dir2
-rwsr-xr-x 1 iamnabins iamnabins    0 Nov  2 14:25 file1
-rw-r--r-- 1 iamnabins iamnabins    0 Nov  2 14:25 file2
```

自然，修改权限也可以写 `chmod u+s file` 来添加特殊权限。  

可能会有人想到，既然特殊权限都在执行位，那么如果执行位并没有提前有"x"占位的话，会怎么样。如果是这样的话，那么对应的特殊权限会大写，表示特殊权限无执行位。
```bash
$ ls -l file1
-rwSrw-rw- 1 iamnabins iamnabins 0 Nov  2 14:40 file1
```
总结：  
| 特殊权限 | 位置 | 数字 | 对象 | 作用 |
| :-- | :-- | :-- | :-- | :-- |
| **SUID** | 属主 x 位 s | 4 | 可执行程序 | 以属主身份运行（如 `passwd`） |
| **SGID** | 属组 x 位 s | 2 | 程序 / 目录 | 继承目录属组（如团队共享目录） |
| **SBIT** | 其他人 x 位 t | 1 | 目录 | 只能删自己的（如 `/tmp`） |

### 其他的特殊权限
1. ACL 权限可以单独给某些用户设置权限。
```bash
$ setfacl -m u:www-data:r file.txt       # -m参数表示修改，-x参数表示删除一条，-b参数表示全部清空
$ getfacl file.txt
# file: file.txt
# owner: iamnabins
# group: iamnabins
user::rw-
user:www-data:r--
group::r--
mask::r--          # mask(掩码)，是对特殊用户/特殊组/传统属组的最高限制，当你敲 chmod g=xxx 时，系统实际上改的是 Mask 的值
other::r--
$ ls -l file.txt
-rw-r--r--+ 1 iamnabins iamnabins 0 Nov  2 15:05 file.txt


$ setfacl -m d:user:www-data:r dir     # 这里的d表示默认/继承，可以让该目录下的对象能够继承 dir 有关 ACL 的信息，比如 mask，特殊用户/组权限等。
```

没有 ACL：chmod 直接改权限位（rwx），没有 Mask。
有了 ACL：chmod 改属组时，会强制顺带修改 Mask。而其他特殊用户的最终权限，看的是自己的规则和 Mask 的交集。
> mask的知识其实并不是非常的常用，据资料显示，是为了解决一个问题：文件里可能塞了十几个特殊用户的规则。如果你随手敲个 chmod g=---，系统怎么保证你的意图（剥夺属组权限）能彻底实现，所以选择将这个权限上限（mask）也降低。

2. 隐藏属性
`chattr +i` 可以让文件无法修改、删除、改名，即便是root。必须先使用 `-i` 把 i 去掉，才可以。
```bash
$ touch file.txt
$ chattr +i file.txt      # 这一步需要root权限，因为设置“不可变属性”太危险了
$ rm -rf file.txt         # 这一步会被拒绝，即便 sudo ....
$ chattr -i file.txt      # 这样就可以了。。。
```
`chattr +a` 可以让文件只允许被追加，适合用来保护日志。该操作同样需要root权限

## （8）打包和压缩
在 **linux** 中，**打包**和**压缩**是两项不同的操作，我们使用 `tar` 和 `gzip` 来分别实现打包和压缩。  

### 1. tar命令
常用参数：
- `-c`：创建
- `-x`：解开
- `-t`：查看
- `-v`：显示过程
- `-f`：包的文件名
- `-z`：gzip
- `-j`：bzip
- `-J`；xz
- `-C`：解压到目录

> -c、-x、-t、-r、-u、-d、-A 是互斥的操作模式，一次只能选一个。

下面给出几个常用的 **tar** 命令语句：
```bash
$ tar -czvf test_dir.tar.gz test_dir
test_dir/
test_dir/b.txt
test_dir/a.txt
$ tar -tzvf test_dir.tar.gz
drwxr-xr-x iamnabins/iamnabins 0 2026-11-02 18:18 test_dir/
-rw-r--r-- iamnabins/iamnabins 0 2026-11-02 18:10 test_dir/b.txt
-rw-r--r-- iamnabins/iamnabins 0 2026-11-02 18:10 test_dir/a.txt
$ mkdir tmp
$ tar -xzvf test_dir.tar.gz -C tmp/
test_dir/
test_dir/b.txt
test_dir/a.txt
$ 
# 可以看出，第一个参数通常是选定模式，第二个参数是选择压缩/解压的算法，-vf基本是一起出现的，可以据此来记忆。我希望你也可以自己手敲一遍。
```
### 2. gzip
也可以使用 **gzip** 单独压缩，**gzip** 压缩文件默认不会保留原文件，可以加 `-k` 参数来保留，**gzip** 不能压缩目录。
```bash
$ gzip file.txt
$ touch file.txt
$ rm file.txt.gz
$ gzip -k file.txt
$ gzip test_dir
gzip: test_dir is a directory -- ignored
```

## （9）软件包
不同的 **linux** 发行版本有不同的软件包安装命令，此处以 **Ubuntu**（Debian系）为例（因为我 wsl 装的就是这个）

下载工具的底层是 **dpkg工具** 下载的，但是这样在下载的时候，可能会出现下载的东西使用时会出现前置依赖缺失的问题。于是，我们通常会使用 **apt** ( dpkg 上的上层前端工具)

这里列举几条管理下载的命令。
- 刷新软件包：
    - `sudo apt update`
- 下载包 (dpkg -i)：
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

> 其实还有用源码来自行编译，获取使用包的方法，可以自行去了解（后续可能会补充这方面的介绍）。

## （10）进程管理
如果说程序是呆在磁盘上的静态文件，进程就是程序的执行，是动态的。

进程有着自己的PID, 占用的内存，cpu，同一个程序可以有多个进程。每个进程都由一个父进程 PPID 创建，所有进程的祖先是 PID 为 1 的 systemd。  

进程通过 **fork系统** 调用来创建，父进程调用一次 `fork()`，会生成一份和自己一模一样的副本，并返还子进程的 PID。子进程调用 `fork()`，会返还 PID 0，可以通过返回值来确定谁是谁。子进程会再调用 `exec()` 来调用要运行的新程序。

比如，使用 **bash** 调用 `ls` 命令时，就是 bash 先自行创建了一个副本（子进程），子进程又 exec() 成了 `ls`。

```c
#include <stdio.h>
#include <unistd.h>

int main(void){
    fork();         # 分裂成两个进程
    fork();         # 两个进程又分别再分裂一次，总共会打印 4 次  
    printf("hello\n");
    return 0
}
```

### 查看进程

使用 `ps aux` 命令来查看进程。
```bash
iamnabins@LAPTOP-JIRKG8RP:~/code/linux-diary$ ps aux | head -5  
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1  24256 15408 ?        Ss   16:45   0:00 /sbin/init
root           2  0.0  0.0   3180  2208 hvc0     Sl+  16:45   0:00 /init
root           7  0.0  0.0   3180  2048 hvc0     Sl+  16:45   0:00 plan9 --control-socket 7 --log-level 4 --server-fd 8 --pipe-fd 10 --log-truncate
root          45  0.0  0.2  50400 16828 ?        S<s  16:45   0:00 /usr/lib/systemd/systemd-journald
```
其中，`%MEM` 是内存占用百分比，`VSZ` 是虚拟内存，`RSS` 是物理内存，`TTY` 是终端。
state(状态)，有以下几种：
- `R`: 运行/就绪
- `S`: 可中断的睡眠（最常见）
- `D`: 不可中断睡眠（如i/o）
- `T`: 暂停
- `Z`: 僵尸进程（子进程已结束，但是父进程没有调用 `wait()` 方法来回收他，在没有大量堆积时，通常无害。

还有一些额外的参数：
- `s`(小写): 表示会话首进程，
- `+`: 前台进程组，比如我调用了 vim，那么他就会有一个 `+` 。

常使用命令 `ps aux | grep sshd` 来查看某个进程的信息。

也可以使用 `top -b -n 1 | head 5` 来列举出进程，`-b` 参数表示批处理，原先的模式是交互模式，在批处理模式下，会占用终端并持续每隔 3 秒追加一次新的进程表。而 `-n` 则是限制了只生成一次，并且无法通过 `P`(按 cpu 排序)，`M`(按内存占用排序)，`k`(按下后输入 PID 即可杀死进程)，`q`(退出) 等按键来控制。

---
结束进程，我们需要使用信号(SIGNAL)，可以使用 `kill -l` 列出所有信号。
以下信号最常用：
- **SIGHUP (1)**: 重读配置
- **SIGINT (2)**: Ctrl+C
- **SIGKILL (9)**: 强制，不可拒绝(建议在先使用 15 号信号结束)
- **SIGTERM (15)**: 正常退出 · kill 默认
- **SIGSTOP (19)**: 暂停

一些命令：
- `kill PID`: 正常退出
- `kill -9 PID`: 强制退出
- `kill all <process name>`: 按照名字退出进程 (不是模糊查询)
- `pkill -u tom`: 结束 tom 的所有进程
---

进程的优先级用 nice 值来确定，范围是 -20 ~ 19，越低优先级越高，默认为10。

```bash
$ nice -n 10 sleep 100 &   # &表示放到后台执行
[1] 5204                   # 作业号（job id），进程号（pid）
$ ps -o pid,ni,cmd -p $!   # $! 表示 当前 Shell 环境中，最近一个被放入后台执行的进程的 PID
    PID  NI CMD
   5204  10 sleep 100
$ renice -n -5 -p $!       # 普通用户无法提高进程的优先级，只能降低。
renice: failed to set priority for 5204 (process ID): Permission denied
```
## （11）作业控制和计划任务

### 作业控制

就在刚刚，我们有说到作业（job），job 可以看作是一种便于人类管理进程任务而产生的说法机制。只在当前的终端环境有效。我的一种解释是：**作业（Job）是当前终端层面的概念，而进程是系统层面的概念**

可以使用 `jobs` 来查看作业。
```bash
$ jobs
[1]   Running                    sleep 500 &
[2]+  Stopped                    sleep 1000
[3]-  Running                    sleep 3000 &
```
这里的 +- 永远跟着你最近一次直接操作（创建、暂停、拉起）的那个后台/暂停作业走。是一个便于表示的占位符。其中 + 表示当前作业，- 表示上一次作业。可以使用 `%+` 来指向这个对应的作业。

调整作业的状态，使用 `bg` 命令 和 `fg` 命令。

`bg %2`：将**处于后台**的 2 号作业开始运行。
`fg %1`：将**处于后台**的 1 号作业拉到前台跑。

> 加了 % 的是作业号，不加的话是 pid 。

关闭终端，作业消失，其实是收到了 SIGHUP (一号信号)，可以使用以下命令来解决这一点。
```bash
nohup ./server.sh &
```
输出默认会写到 nohup.out 文件里。

### 计划任务

使用 at 来创建计划任务（使用 `sudo apt install ad` 来安装，安装前可以先 `sudo apt update`)：
```bash
$ at now + 2 minutes         # 回车后，会进入交互式输入，在命令输入完之后，输入 <EOF> 或 ctrl + d 来结束。
warning: commands will be executed using /bin/sh
at Wed Nov  4 09:26:00 2026
at> sleep 1000
at> <EOT>
job 1 at Wed Nov  4 09:26:00 2026

$ atq        # 列出任务
1       Wed Nov  4 09:26:00 2026 = iamnabins
$ atrm 1     # 删除任务
Warning: deleting running job
```
对于周期性的任务，我们会使用 **cron**，同样，可能需要先检查安装。

每个用户使用 cron 都会有一张 crontab 表，在上面填写定时任务。Ubuntu系列，这张表在 **/var/spool/cron/crontabs/iamnabins**，不同发行版可能略有不同。

填写定时任务的格式请自行查找，这里不多赘述。

下面是使用的命令：
- `crontab -e`：编辑crontab
- `crontab -l`: 列出任务
- `crontab -r`: 清除所有任务（所以如果是想单独删除，请使用编辑功能

系统级的定时任务则需要到 /etc/crontab 和 /etc/cron.d 去编辑，里面的字段会多一个user。

## （12）systemd 和 服务
一些常驻运行的后台进程，例如 sshd, httpd, crond, mysqld，nginx （基本以 d 结尾）我们称其为守护进程（daemon）。由 systemd 1 号进程 管理，systemd 管理的对象被称为单元（unit），单元的类型有：**.service, .target, .socket, .timer, .mount** 等。日常的管理，使用 `systemctl` 命令。

格式为 `systemctl <动作> <服务>`, 例如 `systemctl start sshd`。

动作有以下：
- **start**：启动
- **stop**：停止
- **restart**：重启
- **reload**：重读配置，不中断
- **status**：状态
- **enable**：开机自启
- **disable**：取消自启
- **enable --now**：自启 + 立即启动


**查看状态**：systemctl status sshd --no-pager

单元文件由软件包安装在 **/usr/lib/systemd/system**  
管理员自己写的放在 **/etc/systemd/system**

单元文件的内容，以 sshd.service 为例
```bash
$ cat $(find /usr/lib/systemd/system -name "sshd.service")
[Unit]  # 描述和依赖
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target nss-user-lookup.target auditd.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Service]   # 启动命令
EnvironmentFile=-/etc/default/ssh
ExecStartPre=/usr/sbin/sshd -t
ExecStart=/usr/sbin/sshd -D $SSHD_OPTS
ExecReload=/usr/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=notify
RuntimeDirectory=sshd
RuntimeDirectoryMode=0755

[Install]  # 决定挂载到哪里
WantedBy=multi-user.target
Alias=sshd.service
```

修改了单元文件之后，要执行 `systemctl daemon-reload`，重新读取。

---

systemctl 的日志使用 **journalctl** 来查看：
```bash
$ journalctl -u cron -n 3 --no-pager
Nov 04 11:55:01 LAPTOP-JIRKG8RP CRON[46813]: pam_unix(cron:session): session opened for user iamnabins(uid=1000) by iamnabins(uid=0)
Nov 04 11:55:01 LAPTOP-JIRKG8RP CRON[46815]: (iamnabins) CMD (echo "hello iamnabins" >> ~/hello.txt)
Nov 04 11:55:01 LAPTOP-JIRKG8RP CRON[46813]: pam_unix(cron:session): session closed for user iamnabins
```
可以添加以下参数来实现其他功能：
- **-f**: 持续追踪
- **-b**: 本次开机以来
- **-p err**: 只查看错误
- **since '1 hour ago'**: 查看一小时内的

---

可以使用更加具体的命令来查看 unit 信息。
```bash
$ systemctl list-units --type=service --state=running --no-pager | head -2
  UNIT                        LOAD   ACTIVE SUB     DESCRIPTION
  atd.service                 loaded active running Deferred execution 
```

## （13）磁盘分区，格式化，挂载

物理上的一块硬盘大致需要经过 4 步，能够被系统识别并使用。

1. 分区
2. 格式化
3. 挂载
4. 开机挂载

> 这一段个人觉得有些复杂，暂时先跳过，后续再做讲解。

## （14）网络配置与远程管理（终于开始讲这个了！）

关于网络的一些基础知识，可以前往这里进行了解：[大白话半小时理解网络](https://www.bilibili.com/video/BV1tseyzCEoF)，这里不过多赘述。

### 网络配置

查询设备网卡，我们可以使用 `ip link` 和 `ip addr` 命令。

其中，`ip link` 关注设备自身和其 mac 地址。`ip addr` 还额外关注 ip
信息，其中，addr 是 address 的简写。

查询网关，可以使用 `ip route` 。

```bash
ip -br addr show lo     # -br 表示简短的表示，lo(loop) 表示回环地址
lo       UNKNOWN        127.0.0.1/8 10.255.255.254/32 ::1/128 
```
添加临时 ip 地址（重启即失效）：`ip addr add 192.168.1.50/24 dev eth0`，这里的网卡 eth0 是由于本人使用的 wsl，本质是 windows 系统创建的一个虚拟交换机来实现的，他并不会获取到硬件层面上的 PCI 插槽上的网卡名，所以回退使用了过去的网卡命名。如果是新系统的话，名字可能是别的。

如果想要永久生效，需要写入配置文件，这里以 Ubentu 的写入地址 **/etc/netplan/*.yaml** 为例。

### 远程管理

## Shell 脚本

### (1).shell 脚本的执行

shell 脚本，就是用一个装了 shell 命令的文件去批量的使系统执行。先来看一个最简单的 shell 脚本。
```sh
#!/bin/bash
# 第一个shell脚本
echo "hello $USER"
echo "当前位于: $(pwd)"
```
第一行 **#!** 后面跟着的是 shebeng，指定使用哪个解释器

总共有三种运行 shell 脚本的方法。
分别是: 
```bash
bash hello.sh
./ hello.sh
source hello.sh # 或者 ". hello.sh"，因此也被称为点执行
```
第一种 `bash hello.sh` 指定使用 bash 来解释执行，无需执行权限  
第二种 `./hello.sh` 使用 shebeng 解释执行，需要执行权限（chmod +x hello.sh）  
第三种 `source.sh` 在当前 shell 直接执行

其中前面两种都会开启子shell，而第三种不会。

`bash -x` 会检查sh文件的语法，不执行。
`bash -n` 会在执行时打印命令( + 开头)。

### (2).变量

通过 `变量名=变量` 来设置变量，注意这里的的 `=` 两边不能有空格。  
删除变量使用 `unset <变量>`，  
设置只读变量使用 `readonly 变量名=变量`。

使用变量用 `$变量名` 或 `${变量名}` 。为了能够让变量的使用能够被正常读取，建议在使用变量名时始终加上""。

想让子shell也继承变量，需要在前面加上 export 来导出变量。

---
如果要让shell能够读取键盘的操作，需要使用 `read` 。

```bash
read -p '请输入文本：' name
echo "$name"
```

其中，`-p` 表示显示提示语，`-s` 表示输入不回显（输入密码时可用），`-t 10` 表示持续时间

当输入了参数之后，脚本内部需要调用参数，其中有几个参数需要记住：
- **$0**：脚本名
- **$1**：第一个参数
- **$#**：参数的数量
- $*/$@：每个参数
- **$?**：上一条命令的退出状态（0表示成功）
- **$!**：上一个在后台运行的进程的 PID（进程号）

---

接下来说一下计算的问题，最通用的方法就是使用`$((<要计算的式子>))`，比如 **$((1 + 2))** 。

需要注意的是，linux 计算只能进行整数的计算。
```bash
$ echo $((10 / 3))
3
```
可以使用 bc（linux 内置的任意精度计算器语言）
```bash
$ echo "scale=2; 10 / 3" | bc
3.33
```

### (3).条件判断
在 linux 里面，条件判断写在方括号里：`[ 条件 ]` ，**注意**：条件的两边必须有空格，不然会报错
```bash
$ name='tom'
$ [$name='tom']
[tom=tom]: command not found
```

在条件判断里面(方括号里面)，不能使用"<", ">", "<=" 等，会被认为是重定向，从而引发错误操作。  

使用如下的选项来表示这些:
- 数值比较：
    - **`-eq`**：等于
    - **`-ne`**：不等于
    - **`-gt`**：大于
    - **`-lt`**：小于
    - **`-ge`**：大于等于
    - **`-le`**：小于等于
- 字符串：
    - **`=`** 或 **`==`**：相等
    - **`!=`**：不等
    - **`-z`**：为空
    - **`-n`**：不为空
- 文件类型：
    - **`-e`**：存在
    - **`-f`**：普通文件
    - **`-d`**：目录
    - **`-r`**：可读
    - **`-w`**：可写
    - **`-x`**：可执行
    - **`-s`**：非空
    - **`-L`**：符号链接
- 其他：
    - **`!`**：取反
    - **`-a`**：并且（用于方括号 `[ ]` 内部）
    - **`-o`**：或者（用于方括号 `[ ]` 内部）这两个现在基本不用
    - **`&&`**：并且（用于两个命令之间）
    - **`||`**：或者（用于两个命令之间）

`[[ 条件 ]]` 可以让条件语句内部也可以使用 `$$` 和 `||` ，以及重定向，模式匹配。

示例:
```bash
$ [ 1 -eq 0 ]; echo $?
1
$ [ -z $name ]; echo $?
1
```

前面说过，建议在使用变量的时候在变量两边加上""，这里举一个例子：
```bash
$ name=""; [ $name='tom' ]
$ name=""; [ $name = 'tom' ]
bash: [: =: unary operator expected
```
> 这里还有一个问题，那就是赋值和比较的写法是不同的

---

#### 条件语句

有了条件，就可以写条件语句了，格式为：
```bash
if [ 条件1 ]; then
    echo '条件1 成立'
elif [ 条件2 ]; then
    echo '条件2 成立'
else
    echo '无条件成立'
fi
```

注意，每个有效条件后面都有 `;` 。也可以直接将一条命令作为语句，那么这个命令的结果就会被作为条件
```bash
$ if grep -q tom /etc/passwd; then
> echo 'tom 存在'
> else
> echo 不存在
> fi
不存在
```
总而言之：
- 当你需要做数值比较、字符串比较、文件测试时，用 [ ]。

    - if [ "$a" -eq 1 ]; then （命令去比较，返回 0 或 1 给 if）

    - if [ -f file.txt ]; then （命令去测试文件，返回 0 或 1 给 if）

- 当你直接执行某个程序，看它是否成功时，不需要 [ ]。

    - if ping -c 1 baidu.com; then （ping 成功返回 0，失败返回非 0）

    - if mkdir /tmp/test; then （创建成功返回 0，失败返回非 0）

---

当变量的结果是固定的几种时，使用 **case** 来判断。
格式：
```bash
case $变量名 in
    模式1)
        命令;;
    模式2 | 模式3)
        命令;;
    *)
        命令;;
esac
```
实例:
```shell
#！/bin/bash
# 服务器状态管理
case $1 in
    start)
        echo '服务启动' ;;
    stop)
        echo '服务挂起' ;;
    restart)
        echo '服务重启' ;;
    *)
        echo "服务 $0 可选选项：start | stop | restart"
        exit 1 ;;
esac
```

### (4).循环

#### for 循环
格式:
```bash
for i in 列表
do
    命令
done
```
列表可以用多种形式来获取，包括但不限于:
- for i in 1 2 3
- for i in {1..3}
- for i in $seq(1, 9)

**for 循环** 会结合 **if** 一起来实现，以一个实现乘法表的脚本来实例。
```shell
#!/bin/bash
read -p '请输入乘法表的行数: '
for i in $seq(1, $1)     # 也可以写成 for ((i=1; i<=$lines; i++))，也就是 c语言 的写法
do
    for j in i
    do
        echo "i * j = $((i * j))\t"
    done
    echo
done
```

#### while循环
格式:
```bash
while [ 条件 ]
do
    命令
done
```
示例：
```shell
times=100
sum=0
i=1
while [ $i -le $times ]
do
    sum=$(($sum + $i))
    i=$((i + 1))  # 算数式子里面的变量会自动解析，不用写成 i=$(($i + 1))
done
```
> while 也可以换成 until, 但是是当条件不成立时循环，成立时退出。当然也可以使用 'continue' 和 'break' 来跳出本次或整个循环。

### (5).函数
格式：
```shell
函数() {

}
函数名 参数1 参数2
```
linux 里面的 return 只能返回 0-255 的状态码，想要获取特定的返回值，需要使用 `echo 返回值`，并在后续使用 `$函数(...)` 来接住。函数内部的变量不用传递到外接，需要使用 local 来定义局部变量。

举一个阶乘的例子:   
```bash
func() {
    local n=$1 result=1
    for ((k=1; k<=n; k++))
    do
        result=$((result*k))
    done
    echo $result
}
echo $(func 5)
```
顺便说一下数组的用法:
```bash
arr=(a b c)
echo ${arr[0]} / ${arr[@]} / ${#arr[@]} && echo ${arr[*]}
```

---

下面给出一个用 **shell** 脚本实现的一个例子：




