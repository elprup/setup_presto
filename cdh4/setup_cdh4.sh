#!/bin/bash

get_cred () {
wget http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb
sudo dpkg -i cdh4-repository_1.0_all.deb
}

update_apt () {
sudo apt-get update
}

setup_java () {
sudo apt-get install openjdk-6-jdk
}

setup_client () {
sudo apt-get install hadoop-0.20-mapreduce-tasktracker hadoop-hdfs-datanode
}

make_alter () {
sudo cp -r /etc/hadoop/conf.empty /etc/hadoop/conf.my_cluster
sudo update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.my_cluster 50
sudo update-alternatives --set hadoop-conf /etc/hadoop/conf.my_cluster
}

make_client_storage () {
sudo rm -rf /data/1/dfs/dn
sudo mkdir -p /data/1/dfs/dn
sudo chown -R hdfs:hdfs /data/1/dfs/dn
}



conf_client_storage () {
sudo sed -i 's/\/var\/lib\/hadoop-hdfs\/cache\/hdfs\/dfs\/name/\/data\/1\/dfs\/dn,\/data\/2\/dfs\/dn,\/data\/3\/dfs\/dn/' /etc/hadoop/conf.my_cluster/hdfs-site.xml 
}

make_mapred_storage () {
sudo mkdir -p /data/1/mapred/local /data/2/mapred/local /data/3/mapred/local /data/4/mapred/local
sudo chown -R mapred:hadoop /data/1/mapred/local /data/2/mapred/local /data/3/mapred/local /data/4/mapred/local
}

get_cred
update_apt
setup_java
setup_client
make_alter
make_client_storage
conf_client_storage
make_mapred_storage
