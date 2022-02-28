#!/bin/bash

/etc/init.d/ssh start

# START HADOOP
##############

$HADOOP_HOME/bin/hdfs namenode -format -force

$HADOOP_HOME/sbin/start-dfs.sh

echo "Check the dfs status:"
$HADOOP_HOME/bin/hdfs dfsadmin -report

$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

echo "============================"
echo "All servers started successfully!"
echo "============================"

# START HUE
###########
sleep 20
#/opt/hue/build/env/bin/supervisor &

tail -f /dev/null