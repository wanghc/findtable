# intersystems-findtable
表结构查询工具。因为IRIS的表结构与数据都是以Global方式存储的，取数据时可以使用$p或$lg来取对应字段的值，要找到具体的piece位置则要通过CacheSQLStorage与CacheStorage来查看，不方便，固编写表结构查询工具，通过包名与类名找到所有Index与字段描述，方便开发者编写代码。
## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/wanghc/findtable.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it

Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>write $zv
```
## 进入界面

输入包类，输入类名，点击<查询>按钮得到表结构相关列表
