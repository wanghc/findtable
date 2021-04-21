# findtable

Find table structure tool. 

Because the table structure and data of iris are stored in a global way, when fetching data, you can use $P or $LG to get the value of the corresponding field. To find the specific piece location, you need to view it through cachesqlstorage and cachestorage, which is inconvenient. It is fixed to write a table structure query tool to find all indexes and field descriptions through package name and class name, which is convenient for developers to write code.

## Prerequisites

Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation

1. Clone/git pull the repo into any local directory

    ```
    $ git clone https://github.com/wanghc/findtable.git
    ```

2. Open the terminal in this directory and run:

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

2. Click the find button

3. Find Table Page

   ![演示](https://openexchange.intersystems.com/mp/img/packages/1329/screenshots/ohxdp8skrelyypa0nwi1tbbhyo.gif)