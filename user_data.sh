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
wget https://github.com/Cinnamon/kotaemon/releases/download/v0.5.3/kotaemon-app.zip -O kotaemon-app.zip

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
