#
variable "project" {
  default     = "istio-300820"
}
variable "credentials_file" { 
  default     = "./.ssh/istio-120616846118.json"
}

variable "cluster_name" {
  default     = "jenny"
}

variable "preemptible" {
  description = "preemptible = true for test"
  default     = "true"
}

variable "machine_type_web" {
  description = "... for web pods - Apache"
  default     = "n1-standard-2"
}
#variable "machine_type_web" {
#  description = "... for web pods - Apache"
#  default     = "g1-small"
#}

variable "cluster_user_name" {
  default     = "terra"
}
variable "cluster_user_password" {
  default     = "Vzhe viter hytaie pozzhovklu travu"
}

  