#!/bin/bash -x
#set -e

admin="admin"
reader="sr_analyst"
keytab_location="/cdep/keytabs"
collection1="sensitivelogs"
collection2="logs"
solr_server="sravya-centos64-1.ent.cloudera.com"

#Generate the config files for the collection
rm -rf solr_configs
solrctl instancedir --generate solr_configs
mv solr_configs/conf/solrconfig.xml.secure solr_configs/conf/solrconfig.xml
#Upload the instance directory to ZooKeeper
solrctl instancedir --delete $collection1
solrctl instancedir --delete $collection2
solrctl instancedir --create $collection1 solr_configs
solrctl instancedir --create $collection2 solr_configs
solrctl instancedir --list
#Create the collections
kinit -kt ${keytab_location}/${admin}.keytab ${admin}
solrctl collection --delete $collection1
solrctl collection --delete $collection2
solrctl collection --create $collection1 -s 1
solrctl collection --create $collection2 -s 1
Add data:

for i in {1..10}
do
  curl --negotiate -u: http://${solr_server}:8983/solr/${collection1}/update?stream.body=%3Cadd%3E%3Cdoc%3E%3Cfield+name%3D%22id%22%3Esolrc1doc${i}%3C%2Ffield%3E%3Cfield+name%3D%22description%22%3Esolrc1+test+document+2%3C%2Ffield%3E%3C%2Fdoc%3E%3C%2Fadd%3E
  curl --negotiate -u: http://${solr_server}:8983/solr/${collection2}/update?stream.body=%3Cadd%3E%3Cdoc%3E%3Cfield+name%3D%22id%22%3Esolrc1doc${i}%3C%2Ffield%3E%3Cfield+name%3D%22description%22%3Esolrc1+test+document+2%3C%2Ffield%3E%3C%2Fdoc%3E%3C%2Fadd%3E
done
kinit -kt ${keytab_location}/${reader}.keytab ${reader}
curl --negotiate -u: http://${solr_server}:8983/solr/${collection1}/query?q=*:*
curl --negotiate -u: http://${solr_server}:8983/solr/${collection1}/query?q=*:*

