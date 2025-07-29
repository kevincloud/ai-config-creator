# resource "aws_instance" "togglebank_chat_app" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t3.micro"
#   key_name               = var.key_pair
#   vpc_security_group_ids = [aws_security_group.vault-ec2-sg.id]
#   subnet_id              = aws_subnet.public-subnet.id
#   user_data = templatefile("${path.module}/scripts/install.sh", {
#     AWS_REGION = var.aws_region
#   })
#   iam_instance_profile = aws_iam_instance_profile.togglebank_chat_app.id

#   tags = {
#     Name  = "${var.unique_identifier}-togglebank-chat-app"
#     owner = var.owner
#   }
# }

# resource "aws_security_group" "chat_app_ec2_sg" {
#   name        = "${var.unique_identifier}-chat-app-ec2-sg"
#   description = "ec2-chat-app security group"
#   vpc_id      = aws_vpc.main-vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     owner = var.owner
#   }
# }

# ###
# # EC2 IAM for Allow access
# ###

# resource "aws_iam_role" "vault-ec2-allow-demo-role" {
#   name               = "${var.prefix}-vault-ec2-allow-demo-role"
#   assume_role_policy = data.aws_iam_policy_document.assume-ec2-role.json

#   tags = {
#     Name      = "${var.prefix}-vault-ec2-allow-iam-role"
#     owner     = var.owner
#     se-region = var.se_region
#     purpose   = var.purpose
#     ttl       = var.ttl
#     terraform = var.terraform
#   }
# }

# resource "aws_iam_role_policy" "vault-ec2-allow-demo" {
#   name   = "${var.prefix}-vault-ec2-allow-demo"
#   role   = aws_iam_role.vault-ec2-allow-demo-role.id
#   policy = data.aws_iam_policy_document.vault-ec2-demo.json
# }

# resource "aws_iam_instance_profile" "vault-ec2-allow-demo" {
#   name = "${var.prefix}-vault-ec2-allow-demo"
#   role = aws_iam_role.vault-ec2-allow-demo-role.name

#   tags = {
#     Name      = "${var.prefix}-vault-ec2-allow-instance-profile"
#     owner     = var.owner
#     se-region = var.se_region
#     purpose   = var.purpose
#     ttl       = var.ttl
#     terraform = var.terraform
#   }
# }
