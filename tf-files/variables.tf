variable "ec2-type" {
  default = "t2.micro"
}

variable "rds-type" {
  default = "db.t4g.micro"
}

variable "db-name" {
  default = "phonebook"
}

variable "db-user" {
  default = "admin"
}

# Enter preferred password as String. Using ssm parameters recommended instead.
variable "db-pass" {
  default = ""
}

variable "db-port" {
  default = 3306
}

variable "name-prefix" {
  default = "sfk"
}

variable "key-name" {
  default = "rektozarius"
}

variable "github-repo" {
  default = "https://github.com/rektozarius/202-Terraform-Phonebook-Application-deployed-on-AWS.git"
}