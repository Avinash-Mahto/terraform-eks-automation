# Define the Account_id
aws_account_id = "620456902593"
# Define AWS AMI
aws_ami = "ami-078c1149d8ad719a7"
# Define the Region
region = "ap-southeast-1"
# Define Environment
env = "poc"
# Avialability zone-1a
availability_zone1a = "ap-southeast-1a"
# Avialability zone-1b
availability_zone1b = "ap-southeast-1b"
# VPC CIDR range
vpc_cidr = "10.15.0.0/16"
# VPC Name
vpc_name = "vpc-poc"
# Web Subnet CIDR
web_sub_cidr = "10.15.2.0/23"
# Web subnet name
web_sub_name = "web-subnet"
# App Subnet CIDR - 1a
app_sub_cidr-1a = "10.15.4.0/23"
# App Subnet CIDR - 1b
app_sub_cidr-1b = "10.15.6.0/23"
# App subnet name - 1a
app_sub_name-1a = "app-subnet-1a"
# App subnet name - 1b
app_sub_name-1b = "app-subnet-1b"
# db Subnet CIDR
db_sub_cidr = "10.15.8.0/23"
# App subnet name
db_sub_name = "app-subnet"
# Public route name
pub_route_name = "pub_route"
# Public route name
pri_route_name = "pri_route"
# Internet Gateway
my_igw_name = "poc_igw"
# VPC Route CIDR
 vpc_route_cidr = "0.0.0.0/0"
# Elastic IP Name
 elastic_ip_name =  "elip_poc"
# NAT GW Name
 my_natgw_name = "natgw_poc"
# NAT GW CIDR
natgw_cidr = "0.0.0.0/0"
# Nodename
nodename = "myeks"
# EKS Cluster Name
eks_cluster_name = "my-eks-cluster"
# EKS Nodegroup name
eks_nodegroup_name = "my-nodegroup"

#kms details
key_administrators = [
  "arn:aws:iam::620456902593:role/my-eks-role"

]

key_users = [
  "arn:aws:iam::620456902593:user/admin"
]
