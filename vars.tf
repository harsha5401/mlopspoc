variable "rgname" {
  type        = string
  description = "Name rg group"
  default     = "mlops_learning"
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "northeurope"
}

variable "ml" {
  type        = string
  description = "name of Ml workspace"
  default     = "ml24july"
}
