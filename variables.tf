variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "storage_class" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "gitlabnew_login_key_path" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "minions_count" {
  type = string
 }

 variable "machine_image" {
   type = string
 }

 variable "machine_type" {
   type = string
   
 }

 variable "master_subnet_region" {
   type = string
   description = "default region to put kube-master-related stuff"
 }

  variable "minion_subnet_region" {
   type = string
   description = "default region to put kube-minion-related stuff"
 }

 variable "master_cidr" {
   type = string
   
 }

 variable "minion_cidr" {
   type = string
   
 }

 variable "master_zone" {
   type = string
   
 }
 variable "minion_zone" {
   type = string
   
 }