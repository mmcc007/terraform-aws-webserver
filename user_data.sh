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
wget 'https://lazzloe.s3.us-west-2.amazonaws.com/kotaemon-app.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA6HYWWWDCARH4CWCE%2F20241002%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20241002T021112Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b3ed639f0c1b35156c5b0263966b66d64fb4d708a8346d560ebabf7ac825be76' -O kotaemon-app.zip

# Unzip the file
unzip kotaemon-app.zip
cd data/kotaemon-app

# don't open browser
# sed -i 's/inbrowser=True,/inbrowser=False,/g' ./app.py

# Navigate to the scripts directory
cd scripts

# Make the script executable
chmod +x run_linux.sh

# Set environment variables
export GRADIO_SERVER_PORT=8080
export GRADIO_SERVER_NAME="0.0.0.0"

# Run the script
./run_linux.sh
