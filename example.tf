provider "aws" {
  profile    = "user2"
  region     = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-07c1207a9d40bc3bd"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}