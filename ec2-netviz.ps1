Write-Output "=== EC2 Networking Information (IMDSv2 + Diagram) ==="

# Get IMDSv2 token
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
