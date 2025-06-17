# EC2 NetViz

`ec2-netviz` is a Bash script that fetches metadata from an EC2 instance and prints a clean visual diagram of its networking configuration.

## Features

- Works with IMDSv2
- Shows:
  - Instance ID, AMI, Hostname
  - Public/Private IP
  - Subnet and VPC IDs with CIDRs
  - Security groups
- ASCII diagram output

## Usage

1. SSH into your EC2 instance.
2. Run the script:

```bash
chmod +x ec2-netviz-mac.sh
./ec2-netviz-mac.sh

