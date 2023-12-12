variable "aws_account_id" {
    type = string 
}
variable "aws_ami" {
    type = string 
}
variable "region" {
    type = string
}
variable "availability_zone1a" {
    type = string
}
variable "availability_zone1b" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "web_sub_cidr" {
    type = string
}
variable "web_sub_name" {
    type = string
}
variable "app_sub_cidr-1a" {
    type = string
}
variable "app_sub_cidr-1b" {
    type = string
}
variable "app_sub_name-1a" {
    type = string
}
variable "app_sub_name-1b" {
    type = string
}
variable "db_sub_cidr" {
    type = string
}
variable "db_sub_name" {
    type = string
}
variable "pub_route_name" {
    type = string
}
variable "pri_route_name" {
    type = string
}
variable "my_igw_name" {
    type = string
}
variable "vpc_route_cidr" {
    type = string
}
variable "elastic_ip_name" {
    type = string
}
variable "my_natgw_name" {
    type = string
}
variable "natgw_cidr" {
    type = string
}
variable "nodename" {
    type = string
}
variable "env" {
    type = string
}
variable "key_administrators" {
  description = "List of IAM roles that should have administrator access to the KMS key"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "List of IAM roles that should have administrator access to the KMS key"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  type = string
}
variable "eks_nodegroup_name" {
  type = string
}