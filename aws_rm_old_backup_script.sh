#!/bin/bash

##AWS Cred
. private.sh

#Insert the Inst ID separated with a space
MY_ARRAY=(i-XXXX i-XXXX2)

#Empty Lists
cat /dev/null > ami_list.txt
cat /dev/null > snap_id.txt

for INSTANCE_ID in "${MY_ARRAY[@]}";
do
  aws ec2 describe-images --owners self --filters "Name=tag:InstanceId,Values=$INSTANCE_ID" --query 'Images[*].{ID:ImageId}'  --output=text >> ami_list.txt
  aws ec2 describe-images --owners self --filters "Name=tag:InstanceId,Values=$INSTANCE_ID" --query 'Images[*].BlockDeviceMappings[*].{ID:Ebs.SnapshotId}'  --output=text >>snap_id.txt
done

##Remove old Amis
while read line; do
    aws ec2 deregister-image --image-id $line
done < ami_list.txt

###Remove old Snapshots
while read line; do
    aws ec2 delete-snapshot --snapshot-id $line
done < snap_id.txt
