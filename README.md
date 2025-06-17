# EC2-NetViz

A lightweight tool to extract and visualize AWS EC2 instance networking metadata in a simple terminal diagram format. 
Supports both **Linux (bash)** and **Windows (PowerShell)** environments using IMDSv2.

---

## 📦 Features

- Uses IMDSv2 for enhanced security
- Shows instance, subnet, VPC, AZ, and IP metadata
- Displays network structure using terminal diagrams
- Works on both Linux and Windows EC2 instances

---

## 🐧 Linux Usage (Bash Script)

### Script: `ec2-netviz.sh`

```bash
#!/bin/bash

echo "=== EC2 Networking Information (IMDSv2 + Diagram) ==="

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
  echo "\u250C$(printf '%0.44s' | tr '0' '\u2500')\u2510"
  echo "│                 VPC                        │"
  echo "│      ID: $VPC_ID"
  echo "│      CIDR: $VPC_CIDR"
  echo "│      ┌$(printf '%0.36s' | tr '0' '\u2500')┐"
  echo "│      │           Subnet              │"
  echo "│      │   ID: $SUBNET_ID"
  echo "│      │   CIDR: $SUBNET_CIDR"
  echo "│      │   AZ: $AZ"
  echo "│      │   ┌$(printf '%0.24s' | tr '0' '\u2500')┐"
  echo "│      │   │     EC2 Instance       │"
  echo "│      │   │   ID: $INSTANCE_ID"
  echo "│      │   │   Hostname: $HOSTNAME"
  echo "│      │   │   AMI ID: $AMI_ID"
  echo "│      │   │   Private IP: $PRIVATE_IP"
  echo "│      │   │   Public IP: $PUBLIC_IP"
  echo "│      │   │   MAC: $mac_clean"
  echo "│      │   └$(printf '%0.24s' | tr '0' '\u2500')┘"
  for sg in $SG_IDS; do
    echo "│      │   Security Group: $sg"
  done
  echo "│      └$(printf '%0.36s' | tr '0' '\u2500')┘"
  echo "└$(printf '%0.44s' | tr '0' '\u2500')┘"
done

echo ""
echo "General Security Groups: $SG_NAMES"
echo "Metadata fetch and diagram completed."
```

### Usage:
```bash
chmod +x ec2-netviz.sh
./ec2-netviz.sh
```

---

## 🪟 Windows Usage (PowerShell Script)

### Script: `ec2-netviz.ps1`

```powershell
Write-Output "=== EC2 Networking Information (IMDSv2 + Diagram) ==="

$token = Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" `
  -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" }

$base = "http://169.254.169.254/latest/meta-data"
function Get-Meta {
    param ($path)
    return Invoke-RestMethod -Headers @{ "X-aws-ec2-metadata-token" = $token } -Uri "$base/$path"
}

$instanceId = Get-Meta "instance-id"
$amiId = Get-Meta "ami-id"
$hostname = Get-Meta "hostname"
$privateIp = Get-Meta "local-ipv4"
$publicIp = Get-Meta "public-ipv4"
$az = Get-Meta "placement/availability-zone"
$sgNames = Get-Meta "security-groups"

$macs = Get-Meta "network/interfaces/macs/"
foreach ($mac in $macs) {
    $macClean = $mac.TrimEnd("/")
    $vpcId = Get-Meta "network/interfaces/macs/$macClean/vpc-id"
    $subnetId = Get-Meta "network/interfaces/macs/$macClean/subnet-id"
    $vpcCidr = Get-Meta "network/interfaces/macs/$macClean/vpc-ipv4-cidr-block"
    $subnetCidr = Get-Meta "network/interfaces/macs/$macClean/subnet-ipv4-cidr-block"
    $sgIds = Get-Meta "network/interfaces/macs/$macClean/security-groups"

    Write-Output ""
    Write-Output "┌────────────────────────────────────────────┐"
    Write-Output "│                 VPC                        │"
    Write-Output "│      ID: $vpcId"
    Write-Output "│      CIDR: $vpcCidr"
    Write-Output "│      ┌────────────────────────────────┐"
    Write-Output "│      │           Subnet              │"
    Write-Output "│      │   ID: $subnetId"
    Write-Output "│      │   CIDR: $subnetCidr"
    Write-Output "│      │   AZ: $az"
    Write-Output "│      │   ┌────────────────────────┐"
    Write-Output "│      │   │     EC2 Instance       │"
    Write-Output "│      │   │   ID: $instanceId"
    Write-Output "│      │   │   Hostname: $hostname"
    Write-Output "│      │   │   AMI ID: $amiId"
    Write-Output "│      │   │   Private IP: $privateIp"
    Write-Output "│      │   │   Public IP: $publicIp"
    Write-Output "│      │   │   MAC: $macClean"
    Write-Output "│      │   └────────────────────────┘"
    foreach ($sg in $sgIds) {
        Write-Output "│      │   Security Group: $sg"
    }
    Write-Output "│      └────────────────────────────────┘"
    Write-Output "└────────────────────────────────────────────┘"
}

Write-Output ""
Write-Output "General Security Groups: $sgNames"
Write-Output "Metadata fetch and diagram completed."
```

### Usage:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\ec2-netviz.ps1
```

---

