# Terraform AWS Web Server Deployment

## Overview

This project automates the deployment of a web server on AWS using Terraform. The web server application is packaged in a zip file and hosted on an AWS S3 bucket. The deployment process includes:

- Provisioning an EC2 instance.
- Configuring security groups to allow web traffic.
- Using a user data script to download and run the web server application.
- Automating the packaging and uploading of the application to S3 with an expirable link.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Install Dependencies](#2-install-dependencies)
  - [3. Configure AWS Credentials](#3-configure-aws-credentials)
  - [4. Prepare the Web Server Application](#4-prepare-the-web-server-application)
  - [5. Update Configuration Files](#5-update-configuration-files)
- [Deployment](#deployment)
  - [1. Initialize Terraform](#1-initialize-terraform)
  - [2. Plan the Deployment](#2-plan-the-deployment)
  - [3. Apply the Configuration](#3-apply-the-configuration)
- [Accessing the Web Server](#accessing-the-web-server)
- [Testing Locally](#testing-locally)
- [Clean-Up](#clean-up)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Acknowledgments](#acknowledgments)

---

## Prerequisites

- **Operating System**: macOS
- **AWS Account**: Access to an AWS account with permissions to create EC2 instances, S3 buckets, IAM roles, and security groups.
- **AWS CLI**: Installed and configured on your laptop.
- **Terraform**: Installed on your laptop.
- **SSH Key Pair**: An existing SSH key pair or the ability to generate one.

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
├── terraform.tfvars
├── user_data.sh
├── README.md
```

- **data/**: Contains the unzipped web server application for local testing and modifications.
- **scripts/**: Contains utility scripts, including `zip_upload_s3.sh` for packaging and uploading the application to S3.
- **main.tf**: Terraform configuration file defining resources.
- **variables.tf**: Defines variables used in `main.tf`.
- **terraform.tfvars**: Provides values for the variables.
- **user_data.sh**: Script executed on the EC2 instance during initialization.
- **README.md**: Project documentation.

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/terraform-aws-webserver.git
cd terraform-aws-webserver
```

### 2. Install Dependencies

#### a. Install Terraform

```bash
brew update
brew install terraform
terraform -v
```

#### b. Install AWS CLI

```bash
brew install awscli
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

#### b. Package the Application

Use the provided script to zip the application and upload it to S3.

```bash
cd scripts
chmod +x zip_upload_s3.sh
./zip_upload_s3.sh
```

- **`zip_upload_s3.sh`**: This script zips the contents of the `data/` directory, uploads it to an S3 bucket, and generates an expirable link.
- **S3 Bucket**: Ensure you have an S3 bucket created. The script can create one if it doesn't exist.

#### c. Update `user_data.sh` with the Expirable Link

- The script will output an expirable URL.
- Copy this URL and update the `user_data.sh` file to use it for downloading the application on the EC2 instance.

### 5. Update Configuration Files

#### a. `terraform.tfvars`

Update the variable values as needed:

```hcl
aws_region       = "us-east-1"
ami_id           = "ami-0c94855ba95c71c99"  # Update to your preferred AMI
instance_type    = "t2.micro"
key_name         = "your-key-pair-name"
public_key_path  = "~/.ssh/id_rsa.pub"
web_server_port  = 8080
ssh_port         = 22
your_ip_address  = "your.public.ip.address"
s3_bucket_name   = "your-s3-bucket-name"
```

#### b. `variables.tf`

Ensure all variables are defined appropriately.

#### c. `user_data.sh`

Make sure the download URL is updated with the expirable link from the `zip_upload_s3.sh` script.

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

1. **Retrieve the Public IP Address**

   ```bash
   terraform output instance_public_ip
   ```

2. **Access the Web Server**

   Open your web browser and navigate to:

   ```
   http://<instance_public_ip>:8080
   ```

---

## Testing Locally

- **Local Testing Directory**: `data/`
- **Steps**:
  1. Navigate to the `data/` directory.
  2. Run the web server application according to its documentation.
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

- **SSH Access**: The security group restricts SSH access to your public IP address specified in `terraform.tfvars`.
- **Web Traffic**: The web server port (default `8080`) is open to the internet. Ensure the application is secure.
- **AWS Credentials**: Do not hardcode AWS credentials in any files. Use the AWS CLI configuration.
- **S3 Bucket Access**: The `zip_upload_s3.sh` script generates an expirable link. Ensure that the S3 bucket policies do not expose your application to unauthorized access.
- **Sensitive Data**: Do not commit `terraform.tfvars` or any sensitive information to version control.

---

## Troubleshooting

- **Cannot Access Web Server**:
  - Verify that the security group allows inbound traffic on the web server port.
  - Ensure the application is running on the EC2 instance.
  - Check the EC2 instance's public IP address.

- **Issues with `zip_upload_s3.sh`**:
  - Ensure you have the necessary permissions to upload to S3.
  - Verify that the AWS CLI is configured correctly.

- **Terraform Errors**:
  - Run `terraform validate` to check for syntax errors.
  - Ensure all variables are defined and have correct values.

- **SSH Connection Refused**:
  - Confirm that the SSH key pair exists and is correctly specified.
  - Check that your public IP address is correctly set in `terraform.tfvars`.

---

## Acknowledgments

- **Terraform**: Infrastructure as Code tool used for automating AWS resource provisioning.
- **AWS**: Cloud services provider.
- **Gradio**: Framework for building web-based machine learning applications.
- **Original Application**: [Kotaemon App](https://github.com/Cinnamon/kotaemon)

---

**Note**: Replace placeholders like `your-key-pair-name`, `your.public.ip.address`, and `your-s3-bucket-name` with your actual values.

**Disclaimer**: Ensure you understand the AWS costs associated with running EC2 instances and other resources. Monitor your AWS usage to avoid unexpected charges.

---