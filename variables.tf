variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "tag_name" {
  type = string
  default = "terraform-dev-harshit"
}

variable "CIDR" {
  type = string
  default = "10.1.0.0/16"
}

variable "subnet_cidr" {
    type = string
    default = "10.1.1.0/24"
}

variable "sg_name" {
  type = string
  default = "terraform-sg"
}

variable "key_pair_name" {
  type = string
  default = "terraform-keypair"
}

variable "bucket_name" {
  default = "terraformharshit"
}

variable "bucket_path" {
    default = "KeyPair/"
}

variable "ami" {
  type = string
  default = "ami-0f5daaa3a7fb3378b"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}