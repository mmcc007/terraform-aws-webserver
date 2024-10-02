# Terraform AWS Web Server Deployment

## Overview

This project automates the deployment of a web server on AWS using Terraform. The web server application is packaged in a zip file and hosted on an AWS S3 bucket. The deployment process includes:

- Provisioning an EC2 instance running Amazon Linux 2.
- Configuring security groups to allow web traffic.
- Using a user data script to download and run the web server application.
- Automating the packaging and uploading of the application to S3 with an expirable link.
- Monitoring the instance initialization via SSH and cloud-init logs.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Install Dependencies](#2-install-dependencies)
  - [3. Configure AWS Credentials](#3-configure-aws-credentials)
  - [4. Prepare the Web Server Application](#4-prepare-the-web-server-application)
    - [a. Testing Locally](#a-testing-locally)
    - [b. Create an S3 Bucket](#b-create-an-s3-bucket)
    - [c. Package the Application and Upload to S3](#c-package-the-application-and-upload-to-s3)
  - [5. Update Configuration Files](#5-update-configuration-files)
    - [Using `terraform.tfvars.example`](#using-terraformtfvarsexample)
- [Deployment](#deployment)
  - [1. Initialize Terraform](#1-initialize-terraform)
  - [2. Plan the Deployment](#2-plan-the-deployment)
  - [3. Apply the Configuration](#3-apply-the-configuration)
- [Accessing the Web Server](#accessing-the-web-server)
  - [1. Retrieve the Public IP Address](#1-retrieve-the-public-ip-address)
  - [2. SSH into the EC2 Instance](#2-ssh-into-the-ec2-instance)
  - [3. Monitor Cloud-Init Logs](#3-monitor-cloud-init-logs)
  - [4. Access the Web Server](#4-access-the-web-server)
- [Testing Locally](#testing-locally)
- [Clean-Up](#clean-up)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Acknowledgments](#acknowledgments)

---

## Prerequisites

- **AWS Account**: Access to an AWS account with permissions to create EC2 instances, S3 buckets, IAM roles, and security groups.
- **AWS CLI**: Installed and configured on your local machine.
- **Terraform**: Installed on your local machine.
- **SSH Key Pair**: An existing AWS SSH key pair or the ability to generate one.
- **Public IP Address**: Your public IP address to restrict SSH access.

---

## Project Structure

```
terraform-aws-webserver/
├── data/
│   └── [Web server application files]
├── scripts/
│   ├── zip_upload_s3.sh
│   └── [Additional scripts]
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── user_data.sh
├── README.md
```

- **data/**: Contains the unzipped web server application for local testing and modifications.
- **scripts/**: Contains utility scripts, including `zip_upload_s3.sh` for packaging and uploading the application to S3.
- **main.tf**: Terraform configuration file defining resources.
- **variables.tf**: Defines variables used in `main.tf`.
- **terraform.tfvars.example**: Example variable definitions file.
- **user_data.sh**: Script executed on the EC2 instance during initialization.
- **README.md**: Project documentation.

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/mmcc007/terraform-aws-webserver.git
cd terraform-aws-webserver
```

### 2. Install Dependencies

#### a. Install Terraform

Follow the instructions for your operating system from the [Terraform installation guide](https://learn.hashicorp.com/terraform/getting-started/install.html).

Verify the installation:

```bash
terraform -v
```

#### b. Install AWS CLI

Follow the instructions for your operating system from the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

Verify the installation:

```bash
aws --version
```

### 3. Configure AWS Credentials

Set up your AWS credentials using the AWS CLI:

```bash
aws configure
```

Provide your:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (e.g., `us-east-1`)
- **Default output format** (e.g., `json`)

### 4. Prepare the Web Server Application

#### a. Testing Locally

- The web server application is located in the `data/` directory.
- Test and modify the application as needed to ensure it runs locally and is configured to be accessible over the internet.

#### b. Create an S3 Bucket

Create an S3 bucket using the AWS CLI:

```bash
aws s3 mb s3://your-s3-bucket-name
```

- Replace `your-s3-bucket-name` with a unique bucket name.

#### c. Package the Application and Upload to S3

The `zip_upload_s3.sh` script handles creating the zip file, uploading it to the S3 bucket, setting the expiration, and returning the URL.

From the project root directory:

```bash
cd scripts
./zip_upload_s3.sh
```

- The script will:
  - Zip the web server application from the `data/` directory.
  - Upload the zip file to the specified S3 bucket.
  - Generate a pre-signed URL with an expiration time.
  - Output the URL to be used in the `user_data.sh` script.

**Note**: The script does not need to be made executable with `chmod +x`; it should already have the correct permissions.

#### d. Update `user_data.sh` with the Expirable Link

- Copy the URL generated by `zip_upload_s3.sh`.
- Open `user_data.sh` and update the download command to use the new URL.

Example:

```bash
wget "<pre-signed-url>" -O data.zip
```

Replace `<pre-signed-url>` with the URL from the script output.

### 5. Update Configuration Files

#### Using `terraform.tfvars.example`

A sample variables file `terraform.tfvars.example` is provided. You can use it as a starting point for your own `terraform.tfvars` file.

1. **Copy the Example File**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`

   Open `terraform.tfvars` in your preferred text editor and update the variable values:

   ```hcl
   ami_id          = "ami-0xxxxxxxxxxxxxxxx"  # Example for Amazon Linux 2 in your region
   key_name        = "my-key-pair"
   public_key_path = "~/.ssh/id_rsa.pub"
   web_server_port = 8080
   ```

   - **`ami_id`**: The AMI ID for Amazon Linux 2 in your region.
   - **`key_name`**: The name of your existing AWS key pair.
   - **`public_key_path`**: Path to your public SSH key.
   - **`web_server_port`**: Port number on which your web server listens (default is `8080`).

**Note**: Do not commit `terraform.tfvars` to version control, as it may contain sensitive information. It's included in `.gitignore` by default.

---

## Deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the plan and ensure all resources are correct.

### 3. Apply the Configuration

```bash
terraform apply tfplan
```

Type `yes` when prompted to confirm the deployment.

---

## Accessing the Web Server

### 1. Retrieve the Public IP Address

After the Terraform apply completes, retrieve the public IP address of the EC2 instance:

```bash
terraform output instance_public_ip
```

### 2. SSH into the EC2 Instance

You can SSH into the EC2 instance to monitor the initialization and ensure the web server starts correctly.

```bash
ssh -i "~/.ssh/id_rsa" ec2-user@<instance_public_ip>
```

- Replace `~/.ssh/id_rsa` with the path to your private SSH key if different.
- Replace `<instance_public_ip>` with the actual IP address obtained from the previous step.

### 3. Monitor Cloud-Init Logs

Once logged into the EC2 instance, you can tail the cloud-init output log to monitor the execution of the `user_data.sh` script and the startup of the web server.

```bash
sudo tail -f /var/log/cloud-init-output.log
```

- This command will display the output of the initialization script in real-time.
- You can observe the progress of application download, installation, and startup.
- Look for messages indicating that the web server has started successfully.

**To exit the tail command**, press `Ctrl + C`.

### 4. Access the Web Server

Once the web server has started:

- Open your web browser and navigate to:

  ```
  http://<instance_public_ip>:8080
  ```

- Replace `<instance_public_ip>` with the public IP address of your EC2 instance.

---

## Testing Locally

- **Local Testing Directory**: `data/`
- **Steps**:
  1. Navigate to the `data/` directory.

     ```bash
     cd data
     ```

  2. Run the web server application according to its documentation.

     ```bash
     ./run_linux.sh
     ```

  3. Access it locally via `http://127.0.0.1:8080` to ensure it functions correctly.
  4. Make any necessary modifications to support running on the internet.

---

## Clean-Up

To avoid incurring unnecessary charges, destroy the AWS resources when you're done:

```bash
terraform destroy
```

Confirm the action by typing `yes` when prompted.

---

## Security Considerations

- **SSH Access**: The security group restricts SSH access to your public IP address specified in the security group configuration.
- **Web Traffic**: The web server port (default `8080`) is open to the internet. Ensure the application is secure.
- **AWS Credentials**: Do not hardcode AWS credentials in any files. Use the AWS CLI configuration.
- **S3 Bucket Access**: The pre-signed URL generated for the zip file ensures that the application is not publicly accessible indefinitely.
- **Sensitive Data**: Do not commit `terraform.tfvars` or any sensitive information to version control.
- **IAM Roles**: The EC2 instance uses an IAM role to access the S3 bucket securely without embedding credentials.

---

## Troubleshooting

- **Cannot Access Web Server**:
  - Verify that the security group allows inbound traffic on the web server port.
  - Ensure the application is running on the EC2 instance.
  - Check the EC2 instance's public IP address.
  - Use SSH to connect to the instance and monitor logs.

- **Monitoring Initialization via SSH**:
  - SSH into the instance using the provided instructions.
  - Tail the cloud-init output log:

    ```bash
    sudo tail -f /var/log/cloud-init-output.log
    ```

  - Look for any errors or issues during the execution of `user_data.sh`.

- **Issues with S3 Bucket Creation or Upload**:
  - Ensure you have the necessary permissions to create and access S3 buckets.
  - Verify that the AWS CLI is configured correctly.
  - If the bucket name already exists globally, choose a unique name.

- **Issues with `zip_upload_s3.sh`**:
  - Ensure that the script is functioning correctly.
  - Confirm that the generated URL is correctly added to `user_data.sh`.
  - Check for any errors during the script execution.

- **Terraform Errors**:
  - Run `terraform validate` to check for syntax errors.
  - Ensure all variables are defined and have correct values.
  - Check that the AWS provider plugin is installed.

- **SSH Connection Refused**:
  - Confirm that the SSH key pair exists and is correctly specified.
  - Check that your public IP address is correctly set in the security group configuration.

- **Application Not Starting**:
  - SSH into the instance and check the application logs, if available.
  - Ensure that all dependencies are installed.
  - Verify environment variables are set correctly.

---

## Acknowledgments

- **Terraform**: Infrastructure as Code tool used for automating AWS resource provisioning.
- **AWS**: Cloud services provider.
- **Original Application**: [Kotaemon App](https://github.com/Cinnamon/kotaemon)

---

**Note**: Replace placeholders like `your-s3-bucket-name` and other variable values with your actual information.

**Disclaimer**: Ensure you understand the AWS costs associated with running EC2 instances and other resources. Monitor your AWS usage to avoid unexpected charges.

---