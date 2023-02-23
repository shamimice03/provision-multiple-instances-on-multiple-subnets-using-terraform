## Provision multiple instances on multiple subnets using terraform
Suppose, we are in a situation where we have 3 public subnets and 2 private subnets. And on top of that, we have to provision 3 EC2 instances on each public subnet and 2 EC2 instances on each private subnet.


### See the following charts for a better understanding:
### Public Instances
| Public subnet  | AZ | Instance Count         
| ------------- |:-------------:| :-------------:|
| Public Subnet-1 | ap-northeast-1a |  3
| Public Subnet-1 | ap-northeast-1c |  3
| Public Subnet-3 | ap-northeast-1d |  3

### Private Instances
| Public subnet  | AZ | Instance Count         
| ------------- |:-------------:| :-------------:|
| Private Subnet-1 | ap-northeast-1a |  2
| Private Subnet-1 | ap-northeast-1c |  2

### VPC:
Let's create the VPC:
```
module "vpc" {

  source = "github.com/shamimice03/terraform-aws-vpc"

  vpc_name = "test_vpc"
  cidr     = "192.168.0.0/16"

  azs                 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnet_cidr  = ["192.168.0.0/20", "192.168.16.0/20", "192.168.32.0/20"]
  private_subnet_cidr = ["192.168.48.0/20", "192.168.64.0/20"]

  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_single_nat_gateway = false

  tags = {
    "Team" = "platform-team"
    "Env"  = "test"
  }

}
```

### Local Varibles
To achieve our main goal which is to provision multiple instances on multiple subnets, we can create two local variables like this:

```
locals {
  public_subnets  = module.vpc.public_subnet_id
  private_subnets = module.vpc.private_subnet_id

  public_instance_conf = [
    for index, subnet in local.public_subnets : [
      for i in range(var.public_instance_per_subnet) : {
        ami                    = data.aws_ami.amazon_linux_ami.id
        instance_type          = var.instance_type
        subnet_id              = subnet
        key_name               = aws_key_pair.aws_ec2_access_key.id
        vpc_security_group_ids = [aws_security_group.public_sg.id]
      }
    ]
  ]

  private_instance_conf = [
    for index, subnet in local.private_subnets : [
      for i in range(var.private_instance_per_subnet) : {
        ami                    = data.aws_ami.amazon_linux_ami.id
        instance_type          = var.instance_type
        subnet_id              = subnet
        key_name               = aws_key_pair.aws_ec2_access_key.id
        vpc_security_group_ids = [aws_security_group.private_sg.id]
      }

    ]
  ]
}

```
We can use `terraform console` to see what these two `local` variables will generate:
```
terraform console
local.public_instance_conf
local.private_instance_conf
```
The two `local` variables will generate some like this:
```
> local.public_instance_conf
[
  [
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0b44eb11144e6d50f"
      "vpc_security_group_ids" = [
        "sg-0ee42e72341a10c2a",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0b44eb11144e6d50f"
      "vpc_security_group_ids" = [
        "sg-0ee42e72341a10c2a",
      ]
    },
    {
      "ami" = "ami-0ffac3e16de16665e"
      "instance_type" = "t2.micro"
      "key_name" = "aws_access_key"
      "subnet_id" = "subnet-0b44eb11144e6d50f"
      "vpc_security_group_ids" = [
        "sg-0ee42e72341a10c2a",
      ]
    },
  ],
  ...
  ...
  ...
]
```

But we are still not done. We have to `flatten` the generated configuration. So that, we can use it inside the `aws_instance` resource block.
```
locals {
  public_instance  = flatten(local.public_instance_conf)
  private_instance = flatten(local.private_instance_conf)
}
```
Similary, to check the output after applying `flatten` function. Use `terraform console`
```
> local.public_instance
[
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  },
  {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-05d208119731978c0"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  },
  ...
  ...
  ...
```


### Create Instances - Public 
```
resource "aws_instance" "public_hosts" {
  for_each               = { for key, value in local.public_instance : key => value }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  key_name               = each.value.key_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags = {
    "Name" = "public-instance-${each.key}"
  }
}
```
### Create Instances - Private
```
resource "aws_instance" "private_hosts" {
  for_each               = { for key, value in local.private_instance : key => value }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  key_name               = each.value.key_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags = {
    "Name" = "private-instance-${each.key}"
  }
}
```

In the above configuration the tricky part is the following line: 
`for_each = { for key, value in local.public_instance : key => value }`

The above line will help us to identify the configuration of each instance separately by creating `key` for each of the configuration. If we run `terraform console` once more and run this `{ for key, value in local.public_instance : key => value }` command, then we will see that difference:

```
> {for key, value in local.public_instance : key => value}
{
  "0" = {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  }
  "1" = {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  }
  "2" = {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-0b44eb11144e6d50f"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  }
  "3" = {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-05d208119731978c0"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  }
  "4" = {
    "ami" = "ami-0ffac3e16de16665e"
    "instance_type" = "t2.micro"
    "key_name" = "aws_access_key"
    "subnet_id" = "subnet-05d208119731978c0"
    "vpc_security_group_ids" = [
      "sg-0ee42e72341a10c2a",
    ]
  }
  ...
  ...
  ...
```

