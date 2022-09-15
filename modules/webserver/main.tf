resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

  ingress {
    description = "allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "allow web traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = "true"
  owners = ["amazon"]
  filter {
    name = "virtualization-type"
    values = var.virtualization-type
  }
   filter {
    name = "architecture"
    values = var.architecture
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }



}

resource "aws_key_pair" "ssh-key" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = file(var.public_key_location)

}

resource "aws_instance" "myapp-server" {
  ami                       = "ami-00785f4835c6acf64"
  instance_type             = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }

}