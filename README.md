# terraform-provision-multiple-ec2-instances
Provision multiple instances on multiple subnets using terraform
```
> local.conf
[
  [
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0053604a85960b76f"
      "tags" = {
        "Name" = "public-instance-1"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0053604a85960b76f"
      "tags" = {
        "Name" = "public-instance-1"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0053604a85960b76f"
      "tags" = {
        "Name" = "public-instance-1"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
  ],
  [
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0c2cf5b83b338af4e"
      "tags" = {
        "Name" = "public-instance-2"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0c2cf5b83b338af4e"
      "tags" = {
        "Name" = "public-instance-2"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0c2cf5b83b338af4e"
      "tags" = {
        "Name" = "public-instance-2"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
  ],
  [
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-08eab04f71a97fda3"
      "tags" = {
        "Name" = "public-instance-3"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-08eab04f71a97fda3"
      "tags" = {
        "Name" = "public-instance-3"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-08eab04f71a97fda3"
      "tags" = {
        "Name" = "public-instance-3"
      }
      "vpc_security_group_ids" = [
        "sg-01f951cd35b426567",
      ]
    },
  ],
]

-------


> local.test
[
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0053604a85960b76f"
    "tags" = {
      "Name" = "public-instance-1"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0053604a85960b76f"
    "tags" = {
      "Name" = "public-instance-1"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0053604a85960b76f"
    "tags" = {
      "Name" = "public-instance-1"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0c2cf5b83b338af4e"
    "tags" = {
      "Name" = "public-instance-2"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0c2cf5b83b338af4e"
    "tags" = {
      "Name" = "public-instance-2"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0c2cf5b83b338af4e"
    "tags" = {
      "Name" = "public-instance-2"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-08eab04f71a97fda3"
    "tags" = {
      "Name" = "public-instance-3"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-08eab04f71a97fda3"
    "tags" = {
      "Name" = "public-instance-3"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-08eab04f71a97fda3"
    "tags" = {
      "Name" = "public-instance-3"
    }
    "vpc_security_group_ids" = [
      "sg-01f951cd35b426567",
    ]
  },
]
```