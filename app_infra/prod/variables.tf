variable "vm_size" {
  type = number
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "subnet_cidr" {
    default = "10.20.1.0/24"
}

variable "avail_zones" {
  type    = list(string)
  default = ["eu-west-1b","eu-west-1c"]
}

variable "DB_USERNAME" {
  type = string
}

variable "DB_PASSWORD" {
  type = string
}

variable "DB_DBNAME" {
  type = string
}

variable "env_name" {
  type = string
}