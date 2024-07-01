###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "cloud_password" {
  type = string
}

variable "ubuntu-2004-lts" {
  default = "fd852pbtueis1q0pbt4o"
}

variable "subnet-zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-a"]
}

variable "cidr" {
  type    = map(list(string))
  default = {
    prod = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  }
}

variable "bucket-role" {
  type    = map(string)
  default = {
    role-1 = "admin"
    role-2 = "editor"
    role-3 = "viewer"
  }
}

variable "object" {
  type    = map(string)
  default = {
    object-1 = "terraform.tfstate"
    source-1 = "terraform.tfstate"
  }
}

variable "bucket-name" {
  type    = string
  default = "am-2024-06-diplom"
}

variable "path-to-ssh" {
  type    = string
  default = "~/.ssh/yc.pub"
}