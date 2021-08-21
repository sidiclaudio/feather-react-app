# feather-react-app
Feather react app

# Overview
This repository contains the necessary configuration for deploying a CI/CD pipeline in AWS for deploying a React frontend app, and an Express backend that the frontend connects to.

# Architecture

<img width="730" alt="Screen Shot 2021-08-21 at 4 22 42 AM" src="https://user-images.githubusercontent.com/44326322/130320209-d751f73d-d94e-487b-8d1f-7f805f0b551e.png">


# Solution

**1. Setup CLOUDFORMATION template for preparing an Amazon Linux 2 EC2 instance on which we will install CodeDeploy agent. We will use Cloudformation to deploy the EC2 instance with the user-data script below:**

``` #!/bin/bash
yum -y update
yum -y install ruby
yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto 
```

Create Cloudformation stack using AWS CLI
```
aws cloudformation create-stack --stack-name nodeserverstack --template-body file://node-server-instance.yml
```

Once the server is up - check the status of the codeDeploy agent
```
sudo service codedeploy-agent status
```


**2. Setup AWS CODEBUILD (Optional)**

Write a buildspec.yml file with all the necessary information for building our app


**3. Setup CODEDEPLOY for deploying our project onto our EC2 instance**

Write an appspec.yml with all the instruction for deploying our code. We used three scripts to achieve our goal:

- install.sh -> this script will install globally node and all the utilities needed

```
# add nodejs to yum
curl -sL https://rpm.nodesource.com/setup_lts.x | bash -
yum install nodejs -y #default-jre ImageMagick

# install pm2 module globaly
npm install -g pm2
pm2 update

# install nc utility
yum install nc -y

# delete existing bundle
cd /home/ec2-user
rm -rf backend
rm -rf fontend
```
- run.sh -> this script will start the backend and frontend in the given order as the frontend depends on the backend
```
#!/usr/bin/env bash

cd /home/ec2-user/backend
npm ci
pm2 start index.js

cd /home/ec2-user/frontend
npm ci
pm2 start "npm start"
```
- validate.sh -> this script will validate whether the app is up on port 8080
```
#!/usr/bin/env bash
sleep 10
# validating that the host is up on 8080
nc -zv 127.0.0.1 8080
```

**4. Finally setup CODEPIPELINE to orchestrate the deployment by reaching out to CODEBUILD to build the code and CODEDEPLOY to deploy onto our EC2.**

# Validation

**URL:**

<img width="934" alt="Screen Shot 2021-08-21 at 4 25 28 AM" src="https://user-images.githubusercontent.com/44326322/130320271-7791ccdf-c0e0-4378-968d-7676114e7bb3.png">

**PIPELINE:**

<img width="330" alt="Screen Shot 2021-08-21 at 4 11 35 AM" src="https://user-images.githubusercontent.com/44326322/130320026-4ac0b58c-37e4-4b0d-a5a7-043970c53b8e.png">


# Futur Enhancement
- Move to a serverless architecture.
- Refactor the App to dynamically grab the EC2 instance IP address.
- Add IP address to a Route 53 domain.
