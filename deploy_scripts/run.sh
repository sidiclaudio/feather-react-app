#!/usr/bin/env bash

cd /home/ec2-user/node
npm ci
pm2 start index.js
