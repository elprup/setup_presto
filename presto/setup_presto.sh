#!/bin/bash
UUID=

apt_install(){
sudo apt-get update
sudo apt-get install openjdk-7-jdk uuid 
UUID=$(uuid)
}

wget_presto(){
wget http://search.maven.org/remotecontent?filepath=com/facebook/presto/presto-server/0.52/presto-server-0.52.tar.gz -O presto-server-0.52.tar.gz 
}

wget_discovery(){
wget http://search.maven.org/remotecontent?filepath=io/airlift/discovery/discovery-server/1.15/discovery-server-1.15.tar.gz -O discovery-server-1.15.tar.gz
}

xtar(){
tar xzvf $1
}

mkd(){
sudo mkdir -p $1
sudo chown papaya:papaya $1 
}

conf_presto_node(){
cat > presto-server-0.52/etc/node.properties << EOF
node.environment=production
node.id=$UUID
node.data-dir=/var/presto/data
EOF
}

conf_discovery_node(){
cat > discovery-server-1.15/etc/node.properties << EOF
node.environment=production
node.id=$UUID
node.data-dir=/var/discovery/data
EOF
}

wget_floatjar(){
mkd /var/presto/installation/lib
wget http://repo1.maven.org/maven2/io/airlift/floatingdecimal/0.1/floatingdecimal-0.1.jar -O /var/presto/installation/lib/floatingdecimal-0.1.jar
}

conf_presto_jvm(){
cat > presto-server-0.52/etc/jvm.config << EOF
-server
-Xmx16G
-XX:+UseConcMarkSweepGC
-XX:+ExplicitGCInvokesConcurrent
-XX:+CMSClassUnloadingEnabled
-XX:+AggressiveOpts
-XX:+HeapDumpOnOutOfMemoryError
-XX:OnOutOfMemoryError=kill -9 %p
-XX:PermSize=150M
-XX:MaxPermSize=150M
-XX:ReservedCodeCacheSize=150M
-Xbootclasspath/p:/var/presto/installation/lib/floatingdecimal-0.1.jar
EOF
}

conf_discovery_jvm(){
cat > discovery-server-1.15/etc/jvm.config << EOF
-server
-Xmx1G
-XX:+UseConcMarkSweepGC
-XX:+ExplicitGCInvokesConcurrent
-XX:+AggressiveOpts
-XX:+HeapDumpOnOutOfMemoryError
-XX:OnOutOfMemoryError=kill -9 %p
EOF
}

conf_discovery_config(){
cat > discovery-server-1.15/etc/config.properties << EOF
http-server.http.port=8411
EOF
}

conf_client_presto(){
cat > presto-server-0.52/etc/config.properties << EOF
coordinator=false
datasources=jmx,hive
http-server.http.port=8080
presto-metastore.db.type=h2
presto-metastore.db.filename=var/db/MetaStore
task.max-memory=1GB
discovery.uri=http://hadoop-1:8080
EOF
}

conf_client_jmx(){
mkd presto-server-0.52/etc/catalog
cat > presto-server-0.52/etc/catalog/jmx.properties << EOF
connector.name=jmx
EOF
}

conf_client_hive(){
mkd presto-server-0.52/etc/catalog
cat > presto-server-0.52/etc/catalog/hive.properties << EOF
connector.name=hive-cdh4
hive.metastore.uri=thrift://hadoop-1:9083
EOF
}


setup_common(){
apt_install
wget_presto
xtar presto-server-0.52.tar.gz
wget_discovery
xtar discovery-server-1.15.tar.gz
mkd presto-server-0.52/etc
mkd /var/presto/data
conf_presto_node
wget_floatjar
conf_presto_jvm
mkd /var/discovery/data
mkd discovery-server-1.15/etc
conf_discovery_node
conf_discovery_jvm
conf_discovery_config
}

setup_client(){
setup_common
conf_client_presto
conf_client_jmx
conf_client_hive
}

setup_client


# if java not change
# sudo update-alternatives --config java
