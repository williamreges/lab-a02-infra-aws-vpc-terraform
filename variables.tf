variable "regiao" {
  type        = string
  description = "Região da AWS definida"
  default     = "sa-east-1"
}

variable "private-subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    "private-subnet-1a" = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "sa-east-1a"
    }
    "private-subnet-1c" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "sa-east-1c"
    }
  }
}

variable "public-subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    "public-subnet-1a" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "sa-east-1a"
    }
    "public-subnet-1c" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "sa-east-1c"
    }
  }
}
