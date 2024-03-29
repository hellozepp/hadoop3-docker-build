#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This Dockerfile should be called from dev directory

FROM ubuntu:focal-20210827

ENV JAVA_HOME /work/jdk1.8.0_151
ENV BASE_DIR /opt
ENV HADOOP_HOME /opt/hadoop
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive

RUN rm -rf /var/lib/apt/lists/*  \
    && apt-get clean \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get update \
    && apt-get \
    -o Acquire::http::Pipeline-Depth="0" install \
    -y --no-install-recommends --fix-missing locales \
    apt-utils build-essential software-properties-common  \
    curl wget unzip nano git net-tools vim lrzsz  \
    openssh-server rsync python2.7-dev libxml2-dev \
    libkrb5-dev libffi-dev libldap2-dev python-lxml \
    libxslt1-dev libgmp3-dev libsasl2-dev tree  \
    libsqlite3-dev libmysqlclient-dev && \
   localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
   rm -rf /var/lib/apt/lists/* && \
   mkdir -p /work && \
   apt-get install -y --reinstall build-essential

RUN \
    if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python2.7 /usr/bin/python; fi

## copy jars to Spark/home
ADD lib/"hadoop-3.2.3.tar.gz" $BASE_DIR
ADD lib/"jdk-8u151-linux-x64.tar.gz" $BASE_DIR
RUN ls $BASE_DIR && mv $BASE_DIR/hadoop-3.2.3 $HADOOP_HOME && mv $BASE_DIR/jdk1.8.0_151 $JAVA_HOME && \
    mkdir -p "/home/hadoop/namedir" "/home/hadoop/datadir" "/home/hadoop/tmp"  "/home/hadoop/data/tmp"
# ... uncomment the 2 first lines /bin/sh: 1: cannot create /opt/hadoop/etc/hadoop/hadoop-env.sh: Directory nonexistent
#RUN \
#    wget https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-3.1.1//hadoop-3.1.1.tar.gz && \
#  tar -xzf hadoop-3.1.1.tar.gz && \
#    mv hadoop-3.1.1 $HADOOP_HOME && \
RUN \
    for user in hadoop hdfs yarn mapred hue; do \
         useradd -U -M -d $HADOOP_HOME/ --shell /bin/bash ${user}; \
    done && \
    for user in root hdfs yarn mapred hue; do \
         usermod -G hadoop ${user}; \
    done && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
#    echo "export HDFS_DATANODE_SECURE_USER=hdfs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export PATH="'$PATH'":$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> ~/.bashrc && \
    echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc

ADD core-site.xml $HADOOP_HOME/etc/hadoop/
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/

####################################################################################
# HUE

# https://www.dropbox.com/s/auwpqygqgdvu1wj/hue-4.1.0.tgz
#ADD hue-4.1.0.tgz /


##
#RUN mv -f /hue-4.1.0 /opt/hue
#WORKDIR /opt/hue
#RUN make apps

#RUN chown -R hue:hue /opt/hue

#WORKDIR /

####################################################################################

RUN \
    service ssh restart && \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config

ADD hue.ini /opt/hue/desktop/conf

ADD start-all.sh start-all.sh
# resourceManager 8032，resourceManager ui 8088,resourcemanager.scheduler 8030
# resource-tracker 8031
# resourcemanager.admin 8033
# 获取namenode元数据信息的RPC默认端口 8020 hdfs://hadoop3:8020
# hdfs ui 9870
# secondary.http-address 9001
# containerlogs 8042
EXPOSE 8088 9870 9864 8042 8888 8032 8030 8031 8020 10020 19888 9000 9001 8042
# xdebug->10002
EXPOSE 10002

RUN ln -fs /bin/bash /bin/sh

CMD bash start-all.sh
