variable "instance_type" {
  description = "Name of the project"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "aws_access_key"
}

variable "amazon_linux_host_count" {
  description = "Number of amazon linux host"
  type        = number
  default     = 2
}


variable "private_key_location" {
  description = "Location of the private key"
  type        = string
  default     = "/Users/shamimmd/.ssh/aws_access_key.pem"
}

variable "public_instance_sg_ports" {

  description = "Define the ports and protocols for the security group"
  type        = list(any)
  default = [
    {
      "port" : 22,
      "protocol" : "tcp"
    },
  ]
}

variable "private_instance_sg_ports" {

  description = "Define the ports and protocols for the security group"
  type        = list(any)
  default = [
    {
      "port" : 22,
      "protocol" : "tcp"
    },
  ]
}
