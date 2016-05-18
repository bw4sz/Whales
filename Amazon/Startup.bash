#!/bin/bash 

# spawn instance and store id
instance_id=$(aws ec2 run-instances --image-id ami-bbf20ddb --security-group-ids sg-890a37ed --count 1 --instance-type t2.micro --key-name rstudio --instance-initiated-shutdown-behavior terminate --query 'Instances[0].{d:InstanceId}' --output text)

# wait until instance is up and running
aws ec2 wait instance-running --instance-ids $instance_id

# retrieve public dns
dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicDnsName' --output text | grep a)

# copy over Job.bash to instance
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "C:/Users/Ben/.ssh/rstudio.pem" C:/Users/Ben/Documents/Whales/Amazon/job.bash ubuntu@$dns:~

# run job script on instance
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "C:/Users/Ben/.ssh/rstudio.pem" ubuntu@$dns "bash ~/Job.bash &"

#Once the job is kill, terminate the instance.
aws ec2 terminate-instances --instance-ids $instance_id
