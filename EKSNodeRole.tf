resource "aws_iam_role" "EKSNodeRole" {
  name = "my-EKSNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = ""
  }
}

# Get the policy by name
data "aws_iam_policy" "required-Node-policy" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-EKSNodeRole" {
  role       = aws_iam_role.EKSNodeRole.name
  policy_arn = data.aws_iam_policy.required-Node-policy.arn
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", 
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ])

  role       = aws_iam_role.EKSNodeRole.name
  policy_arn = each.value
}