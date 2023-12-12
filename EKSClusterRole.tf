resource "aws_iam_role" "EKSClusterRole" {
  name = "my-EKSClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = ""
  }
}

# Get the policy by name
data "aws_iam_policy" "required-EKSCluster-policy" {
  name = "AmazonEKSClusterPolicy"
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-EKSClusterRole" {
  role       = aws_iam_role.EKSClusterRole.name
  policy_arn = data.aws_iam_policy.required-EKSCluster-policy.arn
}