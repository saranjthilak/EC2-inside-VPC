# EC2 Inside VPC Terraform Setup

This Terraform configuration creates an AWS EC2 instance inside a custom VPC with a public subnet, internet gateway, route table, and security group.

## Overview

The Terraform script provisions the following resources:

- VPC with CIDR block `10.0.0.0/16`
- Public Subnet with CIDR `10.0.1.0/24`
- Internet Gateway attached to the VPC
- Route Table with route to Internet Gateway
- Security Group allowing SSH (port 22) access from anywhere
- EC2 instance launched inside the public subnet with a specified key pair and AMI

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12+)
- An existing EC2 key pair in your AWS region

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/saranjthilak/EC2-inside-VPC.git
   cd EC2-inside-VPC
