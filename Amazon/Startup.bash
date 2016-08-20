#!/bin/bash 

# spawn instance and store id
instance_id=$(aws ec2 run-instances --image-id ami-ee6da48e --security-group-ids sg-890a37ed --count 1 --instance-type t2.large --key-name rstudio --instance-initiated-shutdown-behavior stop --query 'Instances[0].{d:InstanceId}' --output text)

#Add a cloudwatch
#aws cloudwatch put-metric-alarm --alarm-name cpu-mon --alarm-description "Alarm when CPU exceeds 70 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 70 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=i-12345678" --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:111122223333:MyTopic --unit Percent

# wait until instance is up and running
aws ec2 wait instance-running --instance-ids $instance_id

# retrieve public dns
dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicDnsName' --output text | grep a)

#Wait for port to be ready, takes about a minute.
sleep 60

# copy over Job.bash to instance
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i '/c/Users/Ben/.ssh/rstudio.pem' /c/Users/Ben/Documents/Whales/Amazon/Job.bash ubuntu@$dns:~

# run job script on instance, don't wait for finish and disconnect terminal
nohup ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/c/Users/Ben/.ssh/rstudio.pem" ubuntu@$dns "nohup ./Job.bash" &
