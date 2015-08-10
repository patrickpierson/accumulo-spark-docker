FROM sequenceiq/hadoop-docker

MAINTAINER @mraad <mraad@esri.com>

USER root

ENV PATH $PATH:$HADOOP_PREFIX/bin

RUN chown -R root:root $HADOOP_PREFIX

RUN echo -e "\n* soft nofile 65536\n* hard nofile 65536" >> /etc/security/limits.conf

RUN curl -s http://mirror.cc.columbia.edu/pub/software/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/zookeeper-3.4.6 /usr/local/zookeeper;\
 chown -R root:root /usr/local/zookeeper-3.4.6;\
 mkdir -p /var/zookeeper
ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOOKEEPER_HOME/bin
ADD zookeeper/* $ZOOKEEPER_HOME/conf/

RUN curl -s http://archive.apache.org/dist/accumulo/1.5.2/accumulo-1.5.2-bin.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/accumulo-1.5.2 /usr/local/accumulo;\
 chown -R root:root /usr/local/accumulo-1.5.2
ENV ACCUMULO_HOME /usr/local/accumulo
ENV PATH $PATH:$ACCUMULO_HOME/bin
ADD accumulo/* $ACCUMULO_HOME/conf/

ADD *-all.sh /etc/
RUN chown root:root /etc/*-all.sh;\
 chmod 700 /etc/*-all.sh

ADD init-accumulo.sh /tmp/
RUN /tmp/init-accumulo.sh

#support for Hadoop 2.6.0
RUN curl http://d3kbcqa49mib13.cloudfront.net/spark-1.4.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.4.0-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.4.0-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

#install R
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install R

ENTRYPOINT ["/etc/bootstrap.sh"]
EXPOSE 2181 8042 8088 9000 50095
