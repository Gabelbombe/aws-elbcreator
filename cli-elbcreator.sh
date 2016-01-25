#!/bin/bash

## Pre-requisite -you have aws cli and python is installed locally and you have ConfigReader.py
## and elb.properties in the same directory. Modify elb.properties based on your app

## !!! Modify the healthcheck  (last line which is commented out) for your needs and uncomment
## the line prior the running this script  !!!

elnameextension="-int"
scheme=$(python ConfigReader.py Generic Scheme )
costcenter=$(python ConfigReader.py Tags CostCenter)
application=$(python ConfigReader.py Tags Application)
function=loadbalancer
environment=$(python ConfigReader.py Tags Environment)
securitygroupId1=$(python ConfigReader.py Network SecurityGroupID)
subnetid1a=$(python ConfigReader.py Network Subnets1a)
subnetid1b=$(python ConfigReader.py Network Subnets1b)
subnetid1d=$(python ConfigReader.py Network Subnets1d)
httplbport=$(python ConfigReader.py Listener HTTPLoadBalancerPort)
httpinstanceport=$(python ConfigReader.py Listener HTTPInstancePort)
httpslbport=$(python ConfigReader.py Listener HTTPSLoadBalancerPort)
httpsinstanceport=$(python ConfigReader.py Listener HTTPSInstancePort)
sslcertid=$(python ConfigReader.py Listener SSLCertArn)


if [ x"$costcenter" = x ] ; then
  echo "Empty CostCenter...exiting..." ; exit 1
fi

## Setting up ELBName as per conventions
elbname=$application"-"$environment

if [[ "$elbnameext" =~ ^internet.* ]]; then
  elnameextension="-ext";
fi;

elbname=$elbname$elnameextension
echo "Elbname is $elbname"
echo "trying to create lb with the following.........params"
echo "--load-balancer-name $elbname   --listeners \"Protocol=HTTP,LoadBalancerPort=$httplbport,InstanceProtocol=HTTP,InstancePort=$httpinstanceport\" \"Protocol=HTTPS,LoadBalancerPort=$httpslbport,InstanceProtocol=HTTP,InstancePort=$httpsinstanceport,SSLCertificateId=$sslcertid\" --scheme $scheme --subnets $subnetid1a $subnetid1b $subnetid1d  --security-groups $securitygroupId1 --tags Key=CostCenter,Value=$costcenter Key=Application,Value=$application Key=environment,Value=$environment  Key=Function,Value=$function"


read -r -p "Have you verified the parameters of the ELB to be created? [y/N] " response
case $response in [yY][eE][sS]|[yY])
    echo "Creating elb....hang on....\n"
    aws elb create-load-balancer --load-balancer-name $elbname   --listeners "Protocol=HTTP,LoadBalancerPort=$httplbport,InstanceProtocol=HTTP,InstancePort=$httpinstanceport" "Protocol=HTTPS,LoadBalancerPort=$httpslbport,InstanceProtocol=HTTP,InstancePort=$httpsinstanceport,SSLCertificateId=$sslcertid" --scheme $scheme --subnets $subnetid1a $subnetid1b $subnetid1d  --security-groups $securitygroupId1 --tags Key=CostCenter,Value=$costcenter Key=Application,Value=$application Key=environment,Value=$environment  Key=Function,Value=$function
  ;; *)
    echo "Silently exiting...."
  ;;
esac



## Uncomment if you need this
#aws elb configure-health-check --load-balancer-name $elbname  --health-check Target="HTTP:8200/robots.txt",Interval=6,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=5

## Uncomment if you need this
#aws elb modify-load-balancer-attributes --load-balancer-name $elbname --load-balancer-attributes "{\"ConnectionSettings\":{\"IdleTimeout\":300}}"
