resource "aws_key_pair" "sshkey" {
  key_name   = "ekscl-sshkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAi+Aw9HCR8weUErtpOYgtMYGURjVUIjnQ7d8DqrM56+4x3vDI4kqtRrL6RI5Q8bgYDHhWjLAulR+qqhVqGE9XGRJs9G96DgUee7IRmP+jMkPl0Spa6k7CG//y5+0T3EfNQZJvMl6gOjX1ap85bjRKrfnHk3G6ZX96i+LTI/D5os1Tsv+9QnrPi7oqyDxeOZ5w7GwaVPeAmZO/Jz3UKRX5+kDM6Gq1NiwKbZPcID82uDnql37e1XQYZHDEda1K84w/dII7Y5CPO/NqPS59TNAluv06n5QiLhIimR8tC41HBSfQYUQy5dLBZSptNKfzx1WllPAoxzlrps8L6StbKTES6w== rsa-key-20231211"
}