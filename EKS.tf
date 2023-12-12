# EKS cluster KMS encryption key

resource "aws_kms_key" "myeks_kms_key" {
  description             = "KMS key for ekscl secrets encryption"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  policy = templatefile("${path.module}/kms_policy.json.tpl", {
    key_administrators    = var.key_administrators,
    key_users             = var.key_users,
    aws_account_id        = var.aws_account_id
  })
  tags = {
    Name = "${var.nodename}-${var.env}-ekscl-key"
  }
}

resource "aws_kms_alias" "myeks_kms_key" {
  name          = "alias/${var.nodename}-${var.env}-ekscl-key"
  target_key_id = aws_kms_key.myeks_kms_key.id
}

# Write data code to fetch details of the EKSNodeRole & EKSClusterRole
data "aws_iam_role" "EKSNodeRole" {
  name = "my-EKSNodeRole"
}

data "aws_iam_role" "EKSClusterRole" {
  name = "my-EKSClusterRole"
}

data "aws_key_pair" "ekscl-sshkey" {
  key_name = "ekscl-sshkey"
}

# EKS cluster 
resource "aws_eks_cluster" "myeks-cluster" {
  name     = var.eks_cluster_name
  role_arn = data.aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet-1a.id,
      aws_subnet.private_subnet-1b.id,
      
    ]
    endpoint_private_access = true
    endpoint_public_access  = false

  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.myeks_kms_key.arn
    }
    resources = [
      "secrets"
    ]
  }
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  tags = {
    Name = var.eks_cluster_name
    env  = var.env
    node = "${var.nodename}"
  }
  depends_on = [
    data.aws_iam_role.EKSClusterRole
  ]
}

 data "tls_certificate" "ekscl-oidc-cert" {
   url = aws_eks_cluster.myeks-cluster.identity[0].oidc[0].issuer
 }

# Registering OIDC provider for EKS cluster
resource "aws_iam_openid_connect_provider" "ekscl-oidcpr" {
  url = data.tls_certificate.ekscl-oidc-cert.url
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = data.tls_certificate.ekscl-oidc-cert.certificates[*].sha1_fingerprint
  depends_on      = [aws_eks_cluster.myeks-cluster]
}

resource "aws_eks_addon" "ekscl-cni-addon" {
  cluster_name = aws_eks_cluster.myeks-cluster.name
  addon_name   = "vpc-cni"
  depends_on = [
    data.aws_iam_role.EKSNodeRole,
    aws_eks_node_group.myekscl-nodegroup
  ]
}


resource "aws_eks_addon" "ekscl-coredns-addon" {
  cluster_name = aws_eks_cluster.myeks-cluster.name
  addon_name   = "coredns"
  depends_on = [
    data.aws_iam_role.EKSNodeRole,
    aws_eks_node_group.myekscl-nodegroup
  ]
}

resource "aws_eks_addon" "ekscl-kube-proxy-addon" {
  cluster_name = aws_eks_cluster.myeks-cluster.name
  addon_name   = "kube-proxy"
  depends_on = [
    data.aws_iam_role.EKSNodeRole,
    aws_eks_node_group.myekscl-nodegroup
  ]
}


# eks worker node group configuration
resource "aws_eks_node_group" "myekscl-nodegroup" {
  cluster_name    = aws_eks_cluster.myeks-cluster.name
  node_group_name = var.eks_nodegroup_name
  node_role_arn   = data.aws_iam_role.EKSNodeRole.arn
  subnet_ids = [
    aws_subnet.private_subnet-1a.id,
    aws_subnet.private_subnet-1b.id,
    
  ]
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }
  update_config {
    max_unavailable = 1
  }
  instance_types = [
    "m5.large",
  ]
  disk_size = 100
  remote_access {
    ec2_ssh_key = data.aws_key_pair.ekscl-sshkey.key_name
    source_security_group_ids = [
      aws_security_group.mgmt-security-group.id
    ]
  }

  depends_on = [
    data.aws_iam_role.EKSNodeRole
  ]
  tags = {
    "env"             = "${var.env}"
    "node"            = "${var.nodename}"
    "ISTO_Containers" = "AWS-EKS"

  }

}

data "aws_iam_policy" "ekscl-EKS-LBC-policy" {
  name = "${var.nodename}-${var.env}-EKS-LBC-pl"
}

# Load Balancer Controller IAM Role, permissions policy & trust policy
resource "aws_iam_role" "ekscl-EKS-LBC-Role" {
  name = "${var.nodename}-${var.env}-ekscl-EKS-LBC-Role"
  managed_policy_arns = [
    data.aws_iam_policy.ekscl-EKS-LBC-policy.arn,
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.ekscl-oidcpr.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.ekscl-oidcpr.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${replace(aws_iam_openid_connect_provider.ekscl-oidcpr.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


# security group rule addition to the default EKS security group to allow traffic from the bastion hosts
resource "aws_security_group_rule" "ingress-https-from-bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.mgmt-security-group.id
}

resource "aws_security_group_rule" "ingress_all_traffic" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "ingress_all_traffic_bastion" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.mgmt-security-group.id
}


resource "aws_security_group_rule" "all_traffic_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["10.15.0.0/16"]
}

# HTTPS outbound traffic
resource "aws_security_group_rule" "egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

# RDS outbound traffic from EKS cluster
resource "aws_security_group_rule" "egress_rds" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["10.15.0.0/16"]
}

# HTTP outbound traffic
resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Outbound traffic for EKS cluster.
resource "aws_security_group_rule" "egress_dns_resolver_tcp" {
  type                     = "egress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
}

# Outbound traffic for EKS cluster.
resource "aws_security_group_rule" "egress_dns_resolver_udp" {
  type                     = "egress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
}

# Outbound traffic for EKS cluster.
resource "aws_security_group_rule" "egress_kubelet_API" {
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
}


# Open  2049 outbound port for EFS connectivity
resource "aws_security_group_rule" "egress_efs" {
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  security_group_id = aws_eks_cluster.myeks-cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["10.15.0.0/16"]
}
