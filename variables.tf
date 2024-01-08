variable "vpc_cidr" {
  description = "cidr block"
  type        = string
  default     = "10.124.0.0/16"
}


# variable "public_cidrs" {
#   type    = list(string)
#   default = ["10.123.1.0/24", "10.123.2.0/24"]
# }

# variable "private_cidrs" {
#   type    = list(string)
#   default = ["10.123.3.0/24", "10.123.4.0/24"]
# }

variable "access_ip" {
  type    = list(string)
  default = ["0.0.0.0/0"] # ip address of will be access the public instance in the subnet
}

variable "main_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "main_vol_size" {
  type    = number
  default = 20
}


variable "main_instance_count" {
  type    = number
  default = 1
}

# any security variable should not have a default instead put in tfvars
variable "key_name" {
  type = string

}

variable "public_key_path" {
  type = string
}

variable "private_key_path" {
  type = string
}
