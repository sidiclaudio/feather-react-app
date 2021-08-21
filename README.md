# feather-react-app
Feather react app

# Overview
This repository contains the necessary configuration for deploying a CI/CD pipeline in AWS for deploying a React frontend app, and an Express backend that the frontend connects to.

# Architecture



# Solution

**1. Prepare an Amazon Linux 2 EC2 instance by deploying a CodeDeploy agent. We will use Cloudformation to deploy the EC2 instance with the user-data script below:**

``` #!/bin/bash
yum -y update
yum -y install ruby
yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto 
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

#FUTUR ENHANCEMENT
- Move to a serverless architecture.
- Refactor the App to dynamically grab the EC2 instance IP address.
