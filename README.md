# Creating a VPC Infrastructure on AWS using Terraform

## 🚀 Introduction

This guide provides step-by-step instructions on how to set up a Virtual Private Cloud (VPC) on Amazon Web Services (AWS) utilizing Terraform scripts. The infrastructure includes essential components such as subnets, internet gateway, route tables, and a security group for web access.

## 📋 Prerequisites

- **Terraform:** Ensure Terraform is installed on your system. You can download it from [Terraform.io](https://www.terraform.io/downloads.html).
- **AWS Account:** A valid AWS account to create and manage resources.
- **Access Credentials:** AWS credentials configured locally. Usually, this is done using AWS CLI with `aws configure`.
- **Variables:** Define `var.private-subnets`, `var.public-subnets`, and `local.tag_enviromnent` before executing.
They denote subnet configurations and deployment environment


## ⚙️ Infrastructure Components

![001-RouterAndSecurity-v3.png](docs/001-RouterAndSecurity-v3.png)

### ☁️ 1. VPC Creation

The VPC is a logically isolated section of the AWS cloud. It allows you to launch AWS resources in a virtual network that you define.

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-${local.tag_environment}"
  }
}
```
- **Resource:** [`aws_vpc`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- **CIDR Block:** Defines the IP range for the VPC as `10.0.0.0/16`.
- **Tags:** A `Name` tag is applied for easy identification, leveraging the environment tag defined as
`${local.tag_environment}`

### ☁️ 2. Internet Gateway

An Internet Gateway is required for internet access. It allows resources in your VPC to communicate with the internet.

```hcl
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gtw-${local.tag_environment}"
  }
}
```
-    **Resource:** [`aws_internet_gateway`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
- **Associates** with the VPC to enable internet access.
- **Tags:** Similar `Name` tagging for tracking and organization.

### ☁️ 3. Route Table for Public Access

A Route Table with a specific route is necessary to direct internet-bound traffic through the internet gateway.

```hcl
resource "aws_route_table" "router-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "router-public-${local.tag_environment}"
  }
}
```
- **Resource:** [`aws_route_table`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
- **Purpose:** Routes internet traffic to and from the VPC via the internet gateway.
- **Routes:** Implements a route allowing traffic to `0.0.0.0/0` (all internet addresses) through the gateway.
- **Tags:** Uses environment tagging for clarity.

### ☁️ 4. Subnets

**4.1 Private Subnets**

These are isolated from the internet. Resources within these subnets are not accessible directly from outside the VPC.

```hcl
resource "aws_subnet" "private-subnet" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}
```
- **Resource:** [`aws_subnet`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (Private)
- **Purpose:** Hosts resources that should not be accessible directly from the internet.
- **Configuration:**
- Uses a `for_each` loop to create subnets based on provided `var.private-subnets`.
- Associates with the VPC and specifies `cidr_block` and `availability_zone` per subnet.
- **Tags:** Assigns names based on keys in the variable `var.private-subnets`

**4.2 Public Subnets** 

Resources in public subnets can receive direct internet access, if required.

```hcl
resource "aws_subnet" "public-subnet" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}
```
- **Resource:** [`aws_subnet`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (Public)
- **Purpose:** Hosts resources accessible from the internet, like web servers.
- **Configuration:**
- Uses a `for_each` loop similar to the private subnets but includes `map_public_ip_on_launch = true` for
auto-assigning public IPs.
- **Tags:** Named using keys from `var.public-subnets`.

### ☁️ 5. Route Table Associations

Associating public subnets with the public route table ensures that they will route their traffic through the internet gateway.

```hcl
resource "aws_route_table_association" "associate_route_table_public" {
  for_each       = aws_subnet.public-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.router-public.id
}
```
- **Resource:** [`aws_route_table_association`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)
- **Function:** Associates each public subnet with the public route table for internet connectivity.
- **Configuration:** Utilizes `for_each` to iterate through `aws_subnet.public-subnet` resources

### 🛡️ 6. Security Group for Web Traffic

A Security Group (SG) acts as a virtual firewall controlling inbound and outbound traffic to AWS resources.

```hcl
resource "aws_security_group" "allow_web" {
  name        = "allow-web-${local.tag_environment}"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "sg_allow_web_${local.tag_environment}"
  }
}
```
- **Resource:** [`aws_security_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- **Purpose:** Controls inbound and outbound traffic for web servers.
- **Configuration:**
- **Name:** Sets a name with environment tag `allow-web-${local.tag_environment}`.
- **Description:** Specifies the rules to allow web and SSH traffic inbound, and all traffic outbound

#### Ingress Rules
- **Resource:** [`aws_vpc_security_group_ingress_rule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)
- **SSH Access** (Port 22): Allows SSH traffic from anywhere.
- **HTTP Access** (Port 80): Allows web traffic from anywhere.

```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
```

#### Egress Rules
- **Resource:** [`aws_vpc_security_group_egress_rule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)
- **Allow All Traffic**: Provides outbound access to all destinations.

```hcl
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
```

## 📦 Applying the Terraform Configuration

1. **Initialize Terraform**: Run `terraform init` to prepare the directory for other commands.

2. **Plan Infrastructure**: Use `terraform plan` to preview the changes Terraform will make.

3. **Apply Configuration**: Execute `terraform apply` to create the VPC infrastructure.

### Example Commands:

```bash
terraform init
terraform plan
terraform apply
```

## Conclusion

By following these steps, you will successfully create and configure a VPC on AWS using Terraform. This infrastructure setup forms the foundation for more complex architectures and resource deployments in AWS. Adjust configurations as needed based on specific requirements or environments.

## 🔗 References
* [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
* [Terrform Provider AWS](https://registry.terraform.io/providers/hashicorp/aws/latest)
* [Terraform workflow for provisioning infrastructure](https://developer.hashicorp.com/terraform/cli/run)
---

