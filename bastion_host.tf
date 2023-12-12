resource "aws_instance" "bastion-host" {
  ami           = var.aws_ami # replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet-1a.id
  iam_instance_profile = "SSM-Role-EC2"
  vpc_security_group_ids = ["sg-0a0ab8cca9e90d642"]
  key_name = aws_key_pair.sshkey.id
  user_data = <<-EOF
              Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0
--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
sudo yum  install -y python3
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
--//--
              EOF

  tags = {
    Name = "my-bastion-host"
  }

}