#!/bin/bash
# user_data.sh

# Update the package index
# sudo yum update -y

# Install necessary packages
sudo yum install -y unzip
sudo yum install -y git

# Create a directory for the application
mkdir -p /home/ec2-user/kotaemon-app
cd /home/ec2-user/kotaemon-app

# Download the kotaemon-app.zip file
# wget https://github.com/Cinnamon/kotaemon/releases/download/v0.5.3/kotaemon-app.zip -O kotaemon-app.zip
wget https://lazzloe.s3.us-west-2.amazonaws.com/kotaemon-app.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA6HYWWWDCARH4CWCE%2F20241001%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20241001T231440Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=701fbbed5dd3fe120b8dfdcb623361f77977b87ec977d4d6bbf36d3985e44989

# Unzip the file
unzip kotaemon-app.zip
cd kotaemon-app

# don't open browser
sed -i 's/inbrowser=True,/inbrowser=False,/g' ./app.py

# Navigate to the scripts directory
cd scripts

# Make the script executable
chmod +x run_linux.sh

# Set environment variables
export GRADIO_SERVER_PORT=8080
export GRADIO_SERVER_NAME="0.0.0.0"

# Run the script
./run_linux.sh
