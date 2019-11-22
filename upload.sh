#!/bin/bash
# bash script to
# to run upload.sh [PUBLIC DNS]

# upload to EC2
scp tiles.zip ec2-user@$1:

ssh -o StrictHostKeyChecking=no ec2-user@$1 "unzip tiles.zip"
