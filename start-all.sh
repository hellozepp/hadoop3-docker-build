#!/bin/bash

/etc/init.d/ssh start

# START HADOOP
##############

$HADOOP_HOME/bin/hdfs namenode -format -force

$HADOOP_HOME/sbin/start-dfs.sh

echo "Check the dfs status:"
$HADOOP_HOME/bin/hdfs dfsadmin -report

$HADOOP_HOME/sbin/start-yarn.sh

$HADOOP_HOME/bin/yarn node -list

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
sleep 10
echo "============================"
echo "All servers started successfully!"
echo "============================"

$HADOOP_HOME/bin/hadoop fs -put /home/hadoop/data/* /

# START HUE
###########
#/opt/hue/build/env/bin/supervisor &

tail -f /dev/null