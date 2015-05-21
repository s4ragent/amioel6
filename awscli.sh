#Amazon Linux AMI 2013.09  change if you don't use oregon reqion
ami=ami-5a20b86a
 
#keyname
keyname=oregon1503
 
mac=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/ -s`
VpcId=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/vpc-id -s`
SubnetId=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/subnet-id -s`
Az=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s`
Region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s | perl -pe chop`
SgName=`curl -s http://169.254.169.254/latest/meta-data/security-groups/`
SgId=`aws ec2 describe-security-groups --region $Region --group-names $SgName --query 'SecurityGroups[].GroupId' --output text`

createbaseinstance()
{ 
aws ec2 run-instances --image-id $ami --count 1 --instance-type t2.micro --key-name $keyname --security-group-ids $SgId --subnet-id $SubnetId --associate-public-ip-address --block-device-mappings "[{\"DeviceName\": \"/dev/sdf\",\"Ebs\":{\"VolumeSize\":8,\"DeleteOnTermination\":true,\"VolumeType\":\"gp2\"}}]"
}
startinstance()
{ 
aws ec2 run-instances --image-id $1 --count 1 --instance-type t2.micro --key-name $keyname --security-group-ids $SgId --subnet-id $SubnetId --associate-public-ip-address 
}

createsnapshot()
{
  InstanceId=$1
  DeviceName=$2
  #VolumeId=`aws ec2 describe-volumes --region $Region --query "Volumes[].Attachments[][?Device==\\\`$DeviceName\\\`][?InstanceId==\\\`$InstanceId\\\`].VolumeId" --output text`
  VolumeId=`aws ec2 describe-volumes --region $Region --filters "Name=attachment.instance-id,Values=$InstanceId" "Name=attachment.device,Values=$DeviceName" --query "Volumes[].Attachments[].VolumeId" --output text`
  SnapshotId=`aws ec2 create-snapshot --region $Region --volume-id $VolumeId --query 'SnapshotId' --output text`
  State=`aws ec2 describe-snapshots --region $Region --snapshot-ids $SnapshotId --query 'Snapshots[].State[]' --output text`
  while [ $State = "pending" ]
  do
    sleep 10
    State=`aws ec2 describe-snapshots --region $Region --snapshot-ids $SnapshotId --query 'Snapshots[].State[]' --output text`
  done
  echo $SnapshotId
}



listinstances()
{
  aws ec2 describe-instances --region $Region --query 'Reservations[].Instances[].[InstanceId,NetworkInterfaces[]."PrivateIpAddress"]' --output text
}

createimage(){
snapid=`createsnapshot $1 $2`
cat > blockdevice.json <<EOF
[
        {"DeviceName":"/dev/xvda","Ebs":{"VolumeType":"gp2","DeleteOnTermination":true,"SnapshotId":"$snapid"}}
]
EOF

aws ec2 register-image --root-device-name /dev/xvda --name "Oracle linux6 Latest" --block-device-mappings file://blockdevice.json --virtualization-type hvm --architecture x86_64 --description "Oracle Linux 6 Latest"
}
case "$1" in
"listinstances" ) shift;listinstances;;
"createsnapshot" ) shift;createsnapshot $*;;
"createimage" ) shift;createimage $*;;
"startinstance" ) shift;startinstance $*;;
"createbaseinstance" ) shift;createbaseinstance;;
esac
