# findtable

Find table structure tool. 因为 IRIS 的表结构与数据都是以 Global 方式存储的，取数据时可以使用$p或$lg 来取对应字段的值，要找到具体的 piece 位置则要通过 CacheSQLStorage 与 CacheStorage 来查看，不方便，固编写表结构查询工具，通过包名与类名找到所有 Index 与字段描述，方便开发者编写代码。

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

4. Access [findtable](http://127.0.0.1:56773/csp/user/findglobal.csp) or [findglobal](http://127.0.0.1:56773/csp/user/findglobal.csp) with browser


## How to Test it

Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>write $zv
```

## 进入界面

1. Input PackageName，ClassName / GlobalName

2. Click <Find>

3. Find Table Page

   ![演示](https://openexchange.intersystems.com/mp/img/packages/1329/screenshots/ohxdp8skrelyypa0nwi1tbbhyo.gif)