### Build the container image

```shell
docker build -t username/accumulo-spark github.com/ppiersonbt/accumulo-spark-docker.git
```

### Run the container

```shell
docker run --name accumulo-spark -i -t -P username/accumulo-spark /bin/bash
```

### See all exposed ports

```shell
docker port accumulo-spark | sort -t / -n
```


### Sample Accumulo session in the container

```shell
bash-4.1# accumulo shell -u root -p secret

Shell - Apache Accumulo Interactive Shell
-
- version: 1.5.2
- instance name: accumulo
- instance id: 57fdffe2-5a38-48dd-934f-5d2db507027d
-
- type 'help' for a list of available commands
-
root@accumulo> createtable mytable
root@accumulo mytable> tables
!METADATA
mytable
trace
root@accumulo mytable> insert row1 colf colq value1
root@accumulo mytable> scan
row1 colf:colq []    value1
root@accumulo mytable> exit
```

### Sample Spark session in the container

#### run the spark shell

spark-shell --master yarn-client --driver-memory 1g --executor-memory 1g --executor-cores 1

#### execute the the following command which should return 1000
scala> sc.parallelize(1 to 1000).count()
