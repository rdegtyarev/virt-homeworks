# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}
locals {
  instances = {
    "t2.nano" = "ami-00399ec92321828f5"
    "t2.micro" = "ami-00399ec92321828f5"
    }
  }

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.instances 

  name = "web_2-${each.key}"

  ami                    = "${each.value}"
  instance_type          = "${each.key}"
}