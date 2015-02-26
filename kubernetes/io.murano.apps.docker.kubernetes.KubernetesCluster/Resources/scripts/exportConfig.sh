#!/bin/bash

DEFINITION_DIR=/var/run/murano-kubernetes
cd $DEFINITION_DIR
rm /tmp/application.tgz
rm ./application.tgz.b64

echo "#!/bin/bash" > setup.sh
while read line
do
  name=`echo $line | cut -d' ' -f1`
  kind=`echo $line | cut -d' ' -f2`
  file=`echo $line | cut -d' ' -f3`
  echo "echo 'Creating $kind $name'" >> setup.sh
  echo "kubectl create -f $file" >> setup.sh
done < ./elements.list

tar czf /tmp/application.tgz ./
base64 /tmp/application.tgz > ./application.tgz.b64
