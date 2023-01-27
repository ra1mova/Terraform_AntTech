data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    # bucket = "<bucket_name>"
    path = "../networking/terraform.tfstate"
  }
}
