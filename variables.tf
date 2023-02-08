variable "region" {
  description = "Which region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "port" {
  type    = number
  default = 8080
}

variable "openfga_container_image" {
  description = "Which image to use"
  type        = string
  default     = "openfga/openfga:latest"

}

variable "service_count" {
  description = "The number of OpenFGA replicas to deploy"
  type        = number
  default     = 1
}

variable "migrate" {
  description = "Create the tables on a newly created database"
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "The amount of cpu to give each OpenFGA instance"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The amount of memory to give each OpenFGA instance"
  type        = number
  default     = 512
}

variable "db_type" {
  description = "The storage backend to use. Valid values are `postgres` and `memory`."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  type    = string
  default = "postgres"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "postgres"
}

variable "db_min_capacity" {
  type    = number
  default = 0.5
}

variable "db_max_capacity" {
  type    = number
  default = 1.0
}

variable "additional_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}