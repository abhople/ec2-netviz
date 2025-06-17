#!/bin/bash

echo "=== EC2 Networking Information (IMDSv2 + Diagram) ==="

# Get IMDSv2 token
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

META="http://169.254.169.254/latest/meta-data"
get_meta() {
  curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "$META/$1"
}

INSTANCE_ID=$(get_meta instance-id)
AMI_ID=$(get_meta ami-id)
HOSTNAME=$(get_meta hostname)
PRIVATE_IP=$(get_meta local-ipv4)
PUBLIC_IP=$(get_meta public-ipv4)
AZ=$(get_meta placement/availability-zone)
SG_NAMES=$(get_meta security-groups)

for mac in $(get_meta network/interfaces/macs/); do
  mac_clean=$(echo "$mac" | sed 's|/$||')
  VPC_ID=$(get_meta network/interfaces/macs/$mac_clean/vpc-id)
  SUBNET_ID=$(get_meta network/interfaces/macs/$mac_clean/subnet-id)
  VPC_CIDR=$(get_meta network/interfaces/macs/$mac_clean/vpc-ipv4-cidr-block)
  SUBNET_CIDR=$(get_meta network/interfaces/macs/$mac_clean/subnet-ipv4-cidr-block)
  SG_IDS=$(get_meta network/interfaces/macs/$mac_clean/security-groups)

  echo ""
  echo "┌────────────────────────────────────────────┐"
  echo "│                 VPC                        │"
  echo "│      ID: $VPC_ID"
  echo "│      CIDR: $VPC_CIDR"
  echo "│      ┌────────────────────────────────┐"
  echo "│      │           Subnet              │"
  echo "│      │   ID: $SUBNET_ID"
  echo "│      │   CIDR: $SUBNET_CIDR"
  echo "│      │   AZ: $AZ"
  echo "│      │   ┌────────────────────────┐"
  echo "│      │   │     EC2 Instance       │"
  echo "│      │   │   ID: $INSTANCE_ID"
  echo "│      │   │   Hostname: $HOSTNAME"
  echo "│      │   │   AMI ID: $AMI_ID"
  echo "│      │   │   Private IP: $PRIVATE_IP"
  echo "│      │   │   Public IP: $PUBLIC_IP"
  echo "│      │   │   MAC: $mac_clean"
  echo "│      │   └────────────────────────┘"
  for sg in $SG_IDS; do
    echo "│      │   Security Group: $sg"
  done
  echo "│      └────────────────────────────────┘"
  echo "└────────────────────────────────────────────┘"
done

echo ""
echo "General Security Groups: $SG_NAMES"
echo "Metadata fetch and diagram completed."
